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

@class BridgeDispatcher, BridgeConnection;

@interface Bridge : NSObject {
  
@private
  //Networking stuff
  BridgeConnection* connection;
  BridgeDispatcher* dispatcher;
  id delegate;
}

@property(nonatomic, readonly) NSString* clientId;
@property(nonatomic, retain) BridgeDispatcher* dispatcher;

- (id) initWithAPIKey:(NSString*)apiKey withDelegate:(id) theDelegate;

-(void) connect;
-(void) publishService:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) publishService:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;

-(void) joinChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) joinChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;

-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler;
-(void) leaveChannel:(NSString*)serviceName withHandler:(NSObject<BridgeObjectBase>* )handler andCallback:(NSObject<BridgeObjectBase>*) callback;

-(BridgeRemoteObject*) getService:(NSString*)serviceName;
-(BridgeRemoteObject*) getChannel:(NSString*)channelName;

-(void) _sendWithDestination:(BridgeRemoteObject*)destination andArgs:(NSArray*) args;
-(void) _ready;
-(void) _onError:(NSString*)error;

@end
