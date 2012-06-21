//
//  bridge.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BridgeRemoteObject.h"
#import "BridgeObject.h"
#import "BridgeCallback.h"
#import "BridgeClient.h"

@class BridgeDispatcher, BridgeConnection;

@interface Bridge : NSObject {
  
@private
  //Networking stuff
  BridgeConnection* connection;
  BridgeDispatcher* dispatcher;
  BridgeClient* context;
  id delegate;
}

@property(nonatomic, readonly) NSString* clientId;
@property(nonatomic, retain) BridgeDispatcher* dispatcher;
@property(nonatomic, retain) BridgeClient* context;

-(id) initWithAPIKey:(NSString*)apiKey andDelegate:(id)theDelegate options:(NSDictionary*)options;
-(id) initWithAPIKey:(NSString*)apiKey andDelegate:(id)theDelegate;
-(id) initWithApiKey:(NSString*)apiKey;


-(void) connect;
-(void) publishService:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) publishService:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;

-(void) storeService:(NSString*)name withHandler:(NSObject<BridgeObjectBase>* )bridgeObject;

-(void) joinChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) joinChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;
-(void) joinChannel:(NSString*)channelName withHandler:(NSObject<BridgeObjectBase>* )handler isWriteable:(BOOL)writeable andCallback:(NSObject<BridgeObjectBase>*) callback;

-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;

-(BridgeRemoteObject*) getService:(NSString*)serviceName;
-(BridgeRemoteObject*) getChannel:(NSString*)channelName;

-(void) _sendWithDestination:(BridgeRemoteObject*)destination andArgs:(NSArray*) args;
-(void) _ready;
-(void) _onError:(NSString*)error;

@end
