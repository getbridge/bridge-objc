//
//  bridge.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "bridge.h"

#import "BridgeDispatcher.h"
#import "BridgeJSONCodec.h"
#import "BridgeSystemService.h"

#define CONNECT_HEADER 10
#define CONNECT_BODY 11
#define MESSAGE_HEADER 12
#define MESSAGE_BODY 13
#define OUTGOING 14

#define bridge_callback ^(NSObject* a, ...)

@implementation Bridge

- (id) initWithDelegate:(id) theDelegate
{
  return [self initWithHost:@"localhost" andPort:8080 withDelegate:theDelegate];
}

- (id)initWithHost:(NSString *)hostName andPort:(int)hostPort withDelegate:(id)theDelegate
{
  self = [super init];
  if (self) {
    // Initialization code here.
    sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    host = [hostName retain];
    port = hostPort;
    dispatcher = [[BridgeDispatcher alloc] init];
    delegate = theDelegate;
    
    [dispatcher registerService:[[BridgeSystemService alloc] initWithDispatcher:dispatcher andDelegate:delegate] withName:@"system"];
    reconnectBackoff = 0.1;
  }
  
  return self;
}

- (void) connect
{
  NSError *err = nil;
  if(![sock connectToHost:host onPort:port error:&err]){
    NSLog(@"Could not connect: %@", err);
    return;
  } else {
    NSLog(@"Didn't fail. May work");
    // Send a connect message
    NSData* rawMessageData = [BridgeJSONCodec constructConnectMessageWithId:clientId secret:secret];
    [self _frameAndSendData:rawMessageData];
    
    // Read the client id message
    [sock readDataToLength:4 withTimeout:-1 tag:CONNECT_HEADER];
    return;
  }
}

-(void) publishServiceWithName:(NSString*)serviceName withHandler:(BridgeService* )handler
{
  NSData* rawMessageData = [BridgeJSONCodec constructJoinMessageWithWorkerpool:serviceName];
  [self _frameAndSendData:rawMessageData];
}

-(void) joinChannelWithName:(NSString*)channelName withHandler:(BridgeService* )handler andOnJoinCallback:(BridgeService*) callback
{
  BridgeReference* handlerRef = [dispatcher registerRandomlyNamedService:handler];
  BridgeReference* callbackRef = [dispatcher registerRandomlyNamedService:callback];
  NSData* rawMessageData = [BridgeJSONCodec constructJoinMessageWithChannel:channelName handler:handlerRef callback:callbackRef];
  [self _frameAndSendData:rawMessageData];
}

/* Delegate methods and other internal methods*/

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
      NSLog(@"id|secret: %@", connectMessage);
      
      NSArray* chunks = [connectMessage componentsSeparatedByString:@"|"];
      
      [clientId release];
      clientId = [[chunks objectAtIndex:0] retain];
      [dispatcher setClientId:clientId];
      
      [secret release];
      secret = [[chunks objectAtIndex:1] retain];
      
      if([delegate respondsToSelector:@selector(bridgeDidBecomeReady)]){
        [delegate bridgeDidBecomeReady];
      }
      
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
      
      NSArray* references;
      NSDictionary* root = [BridgeJSONCodec parseRequestString:message withReferenceArray:&references];
      
      for(int refIdx = 0, refLen = [references count]; refIdx < refLen; refIdx++){
        BridgeReference* ref = [references objectAtIndex:refIdx];
        [ref setBridge:self];
      }
      
      BridgeReference* destination = [root objectForKey:@"destination"];
      NSArray* arguments = [root objectForKey:@"args"];
      [dispatcher executeUsingReference:destination withArguments:arguments];
      
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
    NSLog([err localizedDescription]);
    
    SEL connectSelector = @selector(connect);
    NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:connectSelector]];
    [inv setSelector:connectSelector];
    [inv setTarget:self];
    [NSTimer scheduledTimerWithTimeInterval:reconnectBackoff invocation:inv repeats:NO];
    
    reconnectBackoff *= 2;
  }
}

-(void) _sendMessageWithDestination:(BridgeReference *)destination andArgs:(NSArray *)args
{
  NSData* rawData = [BridgeJSONCodec constructSendMessageWithDestination:destination andArgs:args withDispatcher:dispatcher];
  
  [self _frameAndSendData:rawData];
}

-(void) _frameAndSendData:(NSData*)rawData
{
  NSData* framedData = [Bridge appendLengthHeaderToData:rawData];
  [sock writeData:framedData withTimeout:-1 tag:OUTGOING];
}

+ (NSData*) appendLengthHeaderToData:(NSData*) messageData
{
  uint32_t len = [messageData length];
  uint32_t bigEndianLen = CFSwapInt32HostToBig(len);
  
  NSMutableData* result = [NSMutableData dataWithCapacity:4+len];
  [result appendBytes:(&bigEndianLen) length:4];
  [result appendData:messageData];
  
  return result;
}

@end
