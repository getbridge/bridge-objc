//
//  BridgeConnection.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bridge, BridgeSocketBuffer;
@protocol BridgeSocket;

@interface BridgeConnection : NSObject {
  Bridge* bridge;
  
  id<BridgeSocket> sock;
  BridgeSocketBuffer* socket_buffer;
  
  NSString* host;
  int port;

  NSString* clientId;
  NSString* secret;
  NSString* apiKey;
  
  NSURL* redirectorURL;
  
  NSMutableData* responseData;
  
  BOOL secure;
  BOOL reconnect;
  float reconnectBackoff;
}

@property (nonatomic, readonly) NSString* host;
@property (nonatomic, readonly) int port;

@property (nonatomic, retain) NSString* clientId;
@property (nonatomic, retain) NSString* secret;

-(id)initWithApiKey:(NSString*)anApiKey options:(NSDictionary*)options bridge:(Bridge*)bridge;
-(void)start;
-(void)send:(NSData*) data;

-(void)redirector;
-(void)establishConnection;

-(void)send:(NSData*)rawData;
-(void)onOpenFromSocket:(id<BridgeSocket>)socket;
-(void)onClose;
-(void)onConnectMessage:(NSString*)message fromSocket:(id<BridgeSocket>) socket;
-(void)onMessage:(NSString*)message fromSocket:(id<BridgeSocket>) socket;

@end
