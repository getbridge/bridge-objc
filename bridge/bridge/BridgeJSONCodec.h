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

+ (NSDictionary*) parseRequestString:(NSString*)bridgeRequestString withReferenceArray:(NSArray**) references;

+ (NSData*) constructJoinMessageWithWorkerpool:(NSString*)workerpool;
+ (NSData*) constructJoinMessageWithChannel: (NSString*)channel handler: (BridgeReference*) handler callback:(BridgeReference*) callback;
+ (NSData*) constructSendMessageWithDestination:(BridgeReference*)destination andArgs:(NSArray*) args withReferenceArray:(NSArray**) references;
+ (NSData*) constructConnectMessageWithId: (NSString*)sessionId secret: (NSString*) secret;
+ (NSData*) constructConnectMessage;

+ (id) decodeReferencesInObject:(id)object withReferenceArray:(NSArray*) references;
+ (id) encodeReferencesInObject:(id)object withReferenceArray:(NSArray*) references;

@end
