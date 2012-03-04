//
//  bridge.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "BridgeDispatcher.h"

#import "BridgeReference.h"
#import "BridgeService.h"

@class BridgeDispatcher;

@interface Bridge : NSObject {
  
@private
  //Networking stuff
  GCDAsyncSocket* sock;
  
  NSURL* redirectorURL;
  NSString* key;
  NSMutableData* responseData;
  
  NSString* host;
  int port;
  
  NSString* clientId;
  NSString* secret;
  
  BridgeDispatcher* dispatcher;
  id delegate;
  
  float reconnectBackoff;
}

- (id) initWithAPIKey:(NSString*)apiKey withDelegate:(id) theDelegate;
- (id) initWithHost:(NSString*)hostName andPort:(int)port withAPIKey:(NSString*)apiKey withDelegate:(id)theDelegate;
- (id) initWithURL:(NSURL*)url withAPIKey:(NSString*)apiKey withDelegate:(id)theDelegate;

-(void) connect;
-(void) publishService:(NSString*)serviceName withHandler:(BridgeService* )handler;
-(void) publishService:(NSString*)serviceName withHandler:(BridgeService* )handler andCallback:(BridgeService*) callback;

-(void) joinChannel:(NSString*)serviceName withHandler:(BridgeService* )handler;
-(void) joinChannel:(NSString*)serviceName withHandler:(BridgeService* )handler andCallback:(BridgeService*) callback;

-(void) leaveChannel:(NSString*)serviceName withHandler:(BridgeService* )handler;
-(void) leaveChannel:(NSString*)serviceName withHandler:(BridgeService* )handler andCallback:(BridgeService*) callback;

-(BridgeReference*) getService:(NSString*)serviceName;
-(BridgeReference*) getChannel:(NSString*)channelName;

-(void) _sendMessageWithDestination:(BridgeReference*)destination andArgs:(NSArray*) args;
-(void) _frameAndSendData:(NSData*)rawData;

+ (NSData*) appendLengthHeaderToData:(NSData*) messageData;

@end
