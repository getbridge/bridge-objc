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

@interface BridgeTCPSocket (){
  
}

@property(nonatomic, retain) GCDAsyncSocket* sock;
@property(nonatomic, assign) BridgeConnection* connection;

@end


@implementation BridgeTCPSocket
@synthesize sock=sock_, connection=connection_;

-(void) dealloc
{
  [self.sock setDelegate:nil delegateQueue:NULL];
  [self.sock disconnect];

  [self setSock:nil];
  [super dealloc];
}

- (id)initWithConnection:(BridgeConnection*)aConnection isSecure:(BOOL)secure
{
    self = [super init];
    if (self) {
        // Initialization code here.
      GCDAsyncSocket* theSock = [[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()] autorelease];
      
      [self setSock:theSock];
      [self setConnection:aConnection];
      
      NSError *err = nil;
      if(![self.sock connectToHost:[self.connection host] onPort:[self.connection port] error:&err]){
        NSLog(@"Could not connect: %@", err);
      } else {
        // Schedule a read
        if(secure) {
                    
          NSDictionary* sslProperties =
          [NSDictionary dictionaryWithObjectsAndKeys: (NSString *)
           kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
           kCFBooleanFalse, kCFStreamSSLAllowsAnyRoot,
           kCFBooleanTrue, kCFStreamSSLValidatesCertificateChain,
           kCFNull, kCFStreamSSLPeerName,
           kCFBooleanFalse, kCFStreamSSLIsServer,
           nil];
          
          [self.sock startTLS:sslProperties];
        }
        
        [self.sock readDataToLength:4 withTimeout:-1 tag:CONNECT_HEADER];
      }
    }
    
    return self;
}

- (void)send:(NSData*) data
{
  uint32_t len = [data length];
  uint32_t bigEndianLen = CFSwapInt32HostToBig(len);
  
  NSMutableData* framedData = [NSMutableData dataWithCapacity:4+len];
  [framedData appendBytes:(&bigEndianLen) length:4];
  [framedData appendData:data];
  NSLog(@"sending: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
  [self.sock writeData:framedData withTimeout:-1 tag:OUTGOING];
}

#pragma mark GCDAsyncSocket delegate methods
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
  BridgeConnection* connection = [self connection];
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
      [self.sock readDataToLength:bodyLength withTimeout:-1 tag:CONNECT_BODY];
      break;
    }
    case CONNECT_BODY:
    {
      NSString* connectMessage = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
      [self.connection onConnectMessage:connectMessage fromSocket:self];
      [self.sock readDataToLength:4 withTimeout:-1 tag:MESSAGE_HEADER];
      break;
    }
      
    case MESSAGE_HEADER:
    {
      uint32_t* bytesPointer = (uint32_t*)[data bytes];
      uint32_t bodyLength = CFSwapInt32BigToHost(*bytesPointer);
      
      NSLog(@"Body length: %u", bodyLength);
      [self.sock readDataToLength:bodyLength withTimeout:-1 tag:MESSAGE_BODY];
      break;
    }
      
    case MESSAGE_BODY:
    {
      NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
      [self.connection onMessage:message fromSocket:self];
      [self.sock readDataToLength:4 withTimeout:-1 tag:MESSAGE_HEADER];
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
    [self.connection onClose];
  }
}

@end
