//
//  bridge.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "bridge.h"
#import "BridgeJSONCodec.h"

#define CONNECT_HEADER 10
#define CONNECT_BODY 11
#define MESSAGE_HEADER 12
#define MESSAGE_BODY 13
#define OUTGOING 14

@implementation bridge

- (id) init 
{
  return [self initWithHost:@"localhost" andPort:8080];
}

- (id)initWithHost:(NSString *)hostName andPort:(int)hostPort
{
    self = [super init];
    if (self) {
        // Initialization code here.
      sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
      host = [hostName retain];
      port = hostPort;
    }
    
    return self;
}

- (void) connect
{
  NSError *err = nil;
  if(![sock connectToHost:host onPort:port error:&err]){
    NSLog(@"Could not connect: %@", err);
    return;
  }
  
  // Send a connect message
  NSString* connectMessage = [BridgeJSONCodec constructConnectMessage];
  NSData* connectMessageData = [connectMessage dataUsingEncoding:NSUTF8StringEncoding];
  
  [sock writeData:connectMessageData withTimeout:-1 tag:OUTGOING];
  
  
  // Read the client id message
  [sock readDataToLength:4 withTimeout:-1 tag:CONNECT_HEADER];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
  NSLog(@"Cool, I'm connected! That was easy.");
}

-(void) socket:(GCDAsyncSocket*)send didReadData:(NSData *)data withTag:(long)tag
{
  switch (tag) {
    case CONNECT_HEADER:
    {
      uint32_t* bytesPointer = (uint32_t*)[data bytes];
      uint32_t bodyLength = *bytesPointer;
      
      NSLog(@"Connect length: %@", bodyLength);
      break;
    }
    case CONNECT_BODY:
      break;
      
    case MESSAGE_HEADER:
      break;
      
    case MESSAGE_BODY:
      break;
      
    default:
      break;
  }
}

@end
