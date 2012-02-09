//
//  bridge.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "BridgeDispatcher.h"

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

-(void) _frameAndSendData:(NSData*)rawData;

+ (NSData*) appendLengthHeaderToData:(NSData*) messageData;

@end
