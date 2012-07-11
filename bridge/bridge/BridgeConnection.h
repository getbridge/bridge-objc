//
//  BridgeConnection.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bridge, BridgeSocketBuffer, BridgeTCPSocket;
@protocol BridgeSocket;

@interface BridgeConnection : NSObject {

}

@property (nonatomic, copy, readonly) NSString* host;
@property (nonatomic, assign, readonly) int port;

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
