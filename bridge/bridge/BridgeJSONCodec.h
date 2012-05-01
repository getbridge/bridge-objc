//
//  BrJSONCodec.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeRemoteObject, BridgeDispatcher, Bridge;

@interface BridgeJSONCodec : NSObject

+ (NSDictionary*) parseRequestString:(NSString*)requestString bridge:(Bridge*)bridge;

+ (NSData*) createSENDWithDestination:(BridgeRemoteObject *)destination args:(NSArray *)args bridge:(Bridge*)bridge;
+ (NSData*) createJWPWithPool:(NSString*)workerpool callback:(BridgeRemoteObject*)callback;
+ (NSData*) createJCWithChannel: (NSString*)channel handler: (BridgeRemoteObject*) handler callback:(BridgeRemoteObject*) callback;
+ (NSData*) createGETCHANNEL:(NSString *)channel;
+ (NSData*) createCONNECTWithId:(NSString *)sessionId secret:(NSString *)secret apiKey:(NSString*)key; 
+ (NSData*) createCONNECT;
+ (NSDictionary*) parseRedirector:(NSData*)data;

+ (id) decodeReferencesInObject:(id)object bridge:(Bridge*)bridge;
+ (id) encodeReferencesInObject:(id)object bridge:(Bridge*)bridge;

@end
