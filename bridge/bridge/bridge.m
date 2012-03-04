//
//  bridge.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "bridge.h"

#import "BridgeDispatcher.h"
#import "BridgeJSONCodec.h"
#import "BridgeSystemService.h"
#import "JSONKit.h"

#define CONNECT_HEADER 10
#define CONNECT_BODY 11
#define MESSAGE_HEADER 12
#define MESSAGE_BODY 13
#define OUTGOING 14

#define bridge_callback ^(NSObject* a, ...)

@implementation Bridge

/*
 @brief Shorthand initializer that connects to localhost and port 8080
 */
- (id) initWithAPIKey:(NSString*)apiKey withDelegate:(id) theDelegate
{
  self = [super init];
  if (self) {
    // Initialization code here.
    sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    key = [apiKey copy];
    responseData = [[NSMutableData alloc] initWithLength:0];
    host = nil;
    port = -1;
    redirectorURL = [NSURL URLWithString:@"http://redirector.flotype.com"];
    dispatcher = [[BridgeDispatcher alloc] init];
    delegate = theDelegate;
    
    [dispatcher registerService:[[BridgeSystemService alloc] initWithDispatcher:dispatcher andDelegate:delegate] withName:@"system"];
    reconnectBackoff = 0.1;
  }
  
  return self;
}

/*
 @brief Initializer for the Bridge instance
 This method initializes the Bridge object with the given parameters.
 @param hostName A string representing the Bridge server to connect to. May be IPv4, IPv6 address or a domain
 @param hostPort The port on the host to connect to
 @param theDelegate An object that responds to bridgeDidBecomeReady selector. Optionally responds to bridgeDidErrorWithMessage
 */
- (id)initWithHost:(NSString *)hostName andPort:(int)hostPort withAPIKey:(NSString*)apiKey withDelegate:(id)theDelegate
{
  self = [self initWithAPIKey:apiKey withDelegate:theDelegate];
  if (self) {
    // Initialization code here.
    host = [hostName copy];
    port = hostPort;
  }
  return self;
}

- (id) initWithURL:(NSURL*)url withAPIKey:(NSString*)apiKey withDelegate:(id)theDelegate
{
  
  self = [self initWithAPIKey:apiKey withDelegate:delegate];
  if (self) {
    redirectorURL = [url copy];
  }
  return self;
}

- (void) dealloc
{
  [sock release];
  [host release];
  [dispatcher release];
  [responseData release];
  [key release];
  [super dealloc];
}

/*
 @brief Connect to the Bridge server using the network information provided to initializer
 */
- (void) connect
{
  
  if(host != nil && port != -1){
    NSError *err = nil;
    if(![sock connectToHost:host onPort:port error:&err]){
      NSLog(@"Could not connect: %@", err);
      return;
    } else {
      NSLog(@"Didn't fail. May work");
      // Send a connect message
      NSData* rawMessageData = [BridgeJSONCodec constructConnectMessageWithId:clientId secret:secret apiKey:key];
      [self _frameAndSendData:rawMessageData];
      
      // Read the client id message
      [sock readDataToLength:4 withTimeout:-1 tag:CONNECT_HEADER];
      return;
    }
  } else {
    // Talk to the redirector
    NSURL* connectionURL = [redirectorURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%u/json", key]];
    NSURLRequest *request = [NSURLRequest requestWithURL:connectionURL];
    [NSURLConnection connectionWithRequest:request delegate:self];
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
  [handlerRef setMethods:[handler getMethods]];
  
  BridgeReference* callbackRef = [dispatcher registerRandomlyNamedService:callback];
  NSData* rawMessageData = [BridgeJSONCodec constructJoinMessageWithChannel:channelName handler:handlerRef callback:callbackRef];
  [self _frameAndSendData:rawMessageData];
}

-(BridgeReference*) getService:(NSString*)serviceName
{
  BridgeReference* service= [BridgeReference referenceWithRoutingPrefix:@"named" andRoutingId:serviceName andServiceName:serviceName andMethodName:nil];
  [service setBridge:self];
  return service;
}

-(BridgeReference*) getChannel:(NSString*)channelName
{
  NSString* prefixedChannelName = [NSString stringWithFormat:@"channel:%@", channelName];
  BridgeReference* channel =  [BridgeReference referenceWithRoutingPrefix:@"channel" andRoutingId:prefixedChannelName andServiceName:prefixedChannelName andMethodName:nil];
  [channel setBridge:self];
  [self _frameAndSendData:[BridgeJSONCodec constructGetChannelMessage:channelName]];
  return channel;
}

/* Delegate methods and other internal methods*/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  // Show error
  NSLog([error localizedDescription]);
  if([delegate respondsToSelector:@selector(bridgeDidErrorWithMessage:)]) {
    [delegate bridgeDidErrorWithMessage:[error localizedDescription]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // Once this method is invoked, "responseData" contains the complete result
  NSDictionary* result = [responseData objectFromJSONData];
  host = [result objectForKey:@"bridge_host"];
  port = [((NSString*)[result objectForKey:@"bridge_port"]) intValue];
  
  [self connect];
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
      NSLog(@"id|secret: %@", connectMessage);
      
      NSArray* chunks = [connectMessage componentsSeparatedByString:@"|"];
      
      if ([chunks count] == 2) {
        [clientId release];
        clientId = [[chunks objectAtIndex:0] retain];
        [dispatcher setClientId:clientId];
        
        [secret release];
        secret = [[chunks objectAtIndex:1] retain];
        
        if([delegate respondsToSelector:@selector(bridgeDidBecomeReady)]){
          [delegate bridgeDidBecomeReady];
        }
      } else {
        // Probably a remote error. Handle it again as such
        [self socket:send didReadData:data withTag:MESSAGE_BODY];
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
