//
//  BrJSONCodec.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BridgeReference.h"

@interface BridgeJSONCodec : NSObject

+ (NSDictionary*) parseRequestString:(NSString*) bridgeRequestString;

+ (NSData*) constructMessageWithWorkerpool:(NSString*)workerpool;
+ (NSData*) constructMessageWithChannel: (NSString*)channel handler: (BridgeReference*) handler callback:(BridgeReference*) callback;
+ (NSData*) constructConnectMessageWithId: (NSString*)sessionId secret: (NSString*) secret;
+ (NSData*) constructConnectMessage;

@end
