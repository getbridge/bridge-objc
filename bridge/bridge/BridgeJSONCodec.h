//
//  BrJSONCodec.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BridgeJSONCodec : NSObject

+ (NSObject*) decodeBridgeRequest:(NSString*) bridgeRequestString;

+ (NSString*) constructMessageWithWorkerpool:(NSString*) workerpool handlerId: (NSString*) handlerId;
+ (NSString*) constructMessageWithChannel: (NSString*) channel handlerId: (NSString*) handlerId;
+ (NSString*) constructConnectMessageWithId: (NSString*) sessionId secret: (NSString*) secret;
+ (NSString*) constructConnectMessage;

+ (NSArray*) typifyObject: (NSObject*) root;


@end
