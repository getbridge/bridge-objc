//
//  BridgeTCPSocket.m
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeTCPSocket.h"
#import "BridgeSocket.h"
#import "GCDAsyncSocket.h"
#import "BridgeConnection.h"

#define CONNECT_HEADER 10
#define CONNECT_BODY 11
#define MESSAGE_HEADER 12
#define MESSAGE_BODY 13
#define OUTGOING 14

@implementation BridgeTCPSocket

- (id)initWithConnection:(BridgeConnection*)aConnection
{
    self = [super init];
    if (self) {
        // Initialization code here.
      sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
      connection = aConnection;
      
      NSError *err = nil;
      if(![sock connectToHost:[connection host] onPort:[connection port] error:&err]){
        NSLog(@"Could not connect: %@", err);
      } else {
        // Schedule a read
        [sock readDataToLength:4 withTimeout:-1 tag:CONNECT_HEADER];
      }
    }
    
    return self;
}

-(void) dealloc
{
  [sock setDelegate:nil delegateQueue:NULL];
  [sock disconnect];
  [sock release];
  [super dealloc];
}

- (void)send:(NSData*) data
{
  uint32_t len = [data length];
  uint32_t bigEndianLen = CFSwapInt32HostToBig(len);
  
  NSMutableData* framedData = [NSMutableData dataWithCapacity:4+len];
  [framedData appendBytes:(&bigEndianLen) length:4];
  [framedData appendData:data];
  NSLog(@"sending: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
  [sock writeData:framedData withTimeout:-1 tag:OUTGOING];
}

#pragma mark GCDAsyncSocket delegate methods
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
  [connection onOpenFromSocket:self];
}

-(void) socket:(GCDAsyncSocket*)send didReadData:(NSData *)data withTag:(long)tag
{
  switch (tag) {  
    case CONNECT_HEADER:
    {
      uint32_t* bytesPointer = (uint32_t*)[data bytes];
      uint32_t bodyLength = CFSwapInt32BigToHost(*bytesPointer);
      NSLog(@"Connect length: %u", bodyLength);
      [sock readDataToLength:bodyLength withTimeout:-1 tag:CONNECT_BODY];
      break;
    }
    case CONNECT_BODY:
    {
      NSString* connectMessage = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
      [connection onConnectMessage:connectMessage fromSocket:self];
      [sock readDataToLength:4 withTimeout:-1 tag:MESSAGE_HEADER];
      break;
    }
      
    case MESSAGE_HEADER:
    {
      uint32_t* bytesPointer = (uint32_t*)[data bytes];
      uint32_t bodyLength = CFSwapInt32BigToHost(*bytesPointer);
      
      NSLog(@"Body length: %u", bodyLength);
      [sock readDataToLength:bodyLength withTimeout:-1 tag:MESSAGE_BODY];
      break;
    }
      
    case MESSAGE_BODY:
    {
      NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
      [connection onMessage:message fromSocket:self];
      [sock readDataToLength:4 withTimeout:-1 tag:MESSAGE_HEADER];
      break;
    }      
    default:
      break;
  }
}

- (void) socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError *)err
{
  if(err != nil){
    NSLog(@"error: %@", [err localizedDescription]);
    [connection onClose];
  }
}

@end
