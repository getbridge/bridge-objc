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
  NSString* host;
  int port;
  
  NSString* clientId;
  NSString* secret;
  
  BridgeDispatcher* dispatcher;
  id delegate;
  
  float reconnectBackoff;
}

-(id) initWithHost:(NSString*)hostName andPort:(int) port withDelegate:(id) theDelegate;
-(void) connect;
-(void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;
-(void) publishServiceWithName:(NSString*)serviceName withHandler:(BridgeService* )handler;
-(void) publishServiceWithName:(NSString*)serviceName withHandler:(BridgeService* )handler;
-(void) joinChannelWithName:(NSString*)serviceName withHandler:(BridgeService* )handler andOnJoinCallback:(BridgeService*) callback;
-(BridgeReference*) getService:(NSString*)serviceName;
-(BridgeReference*) getChannel:(NSString*)channelName;

-(void) _sendMessageWithDestination:(BridgeReference*)destination andArgs:(NSArray*) args;
-(void) _frameAndSendData:(NSData*)rawData;

+ (NSData*) appendLengthHeaderToData:(NSData*) messageData;

@end
