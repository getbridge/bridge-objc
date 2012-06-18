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
#import "BridgeRemoteObject.h"
#import "BridgeConnection.h"
#import "JSONKit.h"

#define bridge_callback ^(NSObject* a, ...)

@implementation Bridge

@synthesize dispatcher, context;

/*
 @brief Shorthand initializer that connects to localhost and port 8080
 */

-(id) initWithAPIKey:(NSString*)apiKey andDelegate:(id)theDelegate options:(NSDictionary*)options
{
  self = [super init];
  if (self) {
    NSMutableDictionary* defaultOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                @"http://redirector.flotype.com", @"redirector", 
                                                                @"https://redirector.flotype.com", @"secureRedirector",
                                                                [NSNumber numberWithBool:YES], @"reconnect",
                                                                [NSNumber numberWithBool:NO], @"secure",nil];
    [defaultOptions addEntriesFromDictionary:options];
    connection = [[BridgeConnection alloc] initWithApiKey:apiKey options:defaultOptions bridge:self];
    dispatcher = [[BridgeDispatcher alloc] initWithBridge:self];
    delegate = theDelegate;
    
    [dispatcher storeObject:[[BridgeSystemService alloc] initWithBridge:self] withName:@"system"];
  }
  
  return self;
}

- (id) initWithAPIKey:(NSString*)apiKey andDelegate:(id) theDelegate
{
  return [self initWithAPIKey:apiKey andDelegate:theDelegate options:nil];
}

-(id) initWithApiKey:(NSString*)apiKey
{
  return [self initWithAPIKey:apiKey andDelegate:nil];
}

- (void) dealloc
{
  [connection release];
  [dispatcher release];
  [super dealloc];
}

-(void) connect {
  [connection start];
}

-(void) _ready
{
  if([delegate respondsToSelector:@selector(bridgeDidBecomeReady)])
  {
    [delegate bridgeDidBecomeReady];
  }
}

-(void) _onError:(NSString*)error
{
  if([delegate respondsToSelector:@selector(bridgeDidReceiveRemoteError:)])
  {
    [delegate bridgeDidReceiveRemoteError:error];
  }
}

-(void) _sendWithDestination:(BridgeRemoteObject *)destination andArgs:(NSArray *)args {
  NSData* msg = [BridgeJSONCodec createSENDWithDestination:destination args:args bridge:self];
  [connection send:msg];
}

-(void) publishService:(NSString*)name withHandler:(NSObject<BridgeObjectBase>* )bridgeObject 
{
  [self publishService:name withHandler:bridgeObject andCallback:nil];
}

-(void) publishService:(NSString*)name withHandler:(NSObject<BridgeObjectBase>* )bridgeObject andCallback:(NSObject<BridgeObjectBase> *)callback
{
  if([name isEqualToString:@"system"]) {
    NSLog(@"Invalid service %@", name);
  }
  
  if([bridgeObject conformsToProtocol:@protocol(BridgeObject)]) {
    [dispatcher storeObject:bridgeObject withName:name];
  }

  BridgeRemoteObject* callbackRef = nil;
  if([callback conformsToProtocol:@protocol(BridgeObject)]) {
    callbackRef = [dispatcher storeRandomObject:callback];
  } else if ([callback isKindOfClass:[BridgeRemoteObject class]]) {
    callbackRef = (BridgeRemoteObject*) callback;
  }
  
  NSData* msg = [BridgeJSONCodec createJWPWithPool:name callback:callbackRef];
  [connection send:msg];
}

-(BridgeRemoteObject*) getService:(NSString*)serviceName
{
  BridgeRemoteObject* service = [BridgeRemoteObject serviceReference:serviceName bridge:self methods:nil];
  return service;
}

-(BridgeRemoteObject*) getChannel:(NSString*)channelName
{
  NSData* msg = [BridgeJSONCodec createGETCHANNEL:channelName];
  [connection send:msg];
  BridgeRemoteObject* channel =  [BridgeRemoteObject channelReference:channelName bridge:self methods:nil];
  return channel;
}

-(void) joinChannel:(NSString*)channelName withHandler:(NSObject<BridgeObjectBase>* )handler
{
  [self joinChannel:channelName withHandler:handler isWriteable:YES andCallback:nil];
}

-(void) joinChannel:(NSString*)channelName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback
{
  [self joinChannel:channelName withHandler:handler isWriteable:YES andCallback:callback]; 
}

-(void) joinChannel:(NSString*)channelName withHandler:(NSObject<BridgeObjectBase>* )handler isWriteable:(BOOL)writeable andCallback:(NSObject<BridgeObjectBase>*) callback
{
  BridgeRemoteObject* handlerRef = nil;
  if([handler conformsToProtocol:@protocol(BridgeObject)]) {
    handlerRef = [dispatcher storeRandomObject:handler];
  } else if ([callback isKindOfClass:[BridgeRemoteObject class]]) {
    handlerRef = (BridgeRemoteObject*) handler;
  }
  
  BridgeRemoteObject* callbackRef = nil;
  if([callback conformsToProtocol:@protocol(BridgeObject)]) {
    callbackRef = [dispatcher storeRandomObject:callback];
  } else if ([callback isKindOfClass:[BridgeRemoteObject class]]) {
    callbackRef = (BridgeRemoteObject*) callback;
  }

  NSData* msg = [BridgeJSONCodec createJCWithChannel:channelName handler:handlerRef writeable:writeable callback:callbackRef];
  [connection send:msg];
}

-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler
{
  
}

-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback
{
  
}

-(NSString*) clientId
{
  return [connection clientId];
}

@end
