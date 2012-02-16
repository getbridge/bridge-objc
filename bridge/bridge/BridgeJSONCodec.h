//
//  BrJSONCodec.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeReference;
@class BridgeDispatcher;

@interface BridgeJSONCodec : NSObject

+ (NSDictionary*) parseRequestString:(NSString*)bridgeRequestString withReferenceArray:(NSArray**) references;

+ (NSData*) constructJoinMessageWithWorkerpool:(NSString*)workerpool;
+ (NSData*) constructJoinMessageWithChannel: (NSString*)channel handler: (BridgeReference*) handler callback:(BridgeReference*) callback;
+ (NSData*) constructSendMessageWithDestination:(BridgeReference*)destination andArgs:(NSArray*) args withDispatcher:(BridgeDispatcher*) dispatcher;
+ (NSData*) constructConnectMessageWithId: (NSString*)sessionId secret: (NSString*) secret;
+ (NSData*) constructConnectMessage;

+ (id) decodeReferencesInObject:(id)object withReferenceArray:(NSArray*) references;
+ (id) encodeReferencesInObject:(id)object withDispatcher:(BridgeDispatcher*) dispatcher;

@end
