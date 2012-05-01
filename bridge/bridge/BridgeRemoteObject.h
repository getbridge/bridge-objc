//
//  BridgeReference.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BridgeObjectBase.h"

@class Bridge;

@interface BridgeRemoteObject : NSObject <BridgeObjectBase> {
  NSString* routingPrefix;
  NSString* routingId;
  NSString* serviceName;
  NSString* methodName;
  NSArray* methods;
  
  Bridge* _bridge;
}

@property(nonatomic, copy) NSString* routingPrefix;
@property(nonatomic, copy) NSString* routingId;
@property(nonatomic, copy) NSString* serviceName;
@property(nonatomic, copy) NSString* methodName;
@property(nonatomic, retain) NSArray* methods;

- (id)initWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName bridge:(Bridge*) bridge methods:(NSArray*) methods;
-(NSDictionary*) dictionaryFromReference;

-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
-(void) forwardInvocation:(NSInvocation *)anInvocation;
-(void) setBridge:(Bridge*) bridge;

+ (BridgeRemoteObject*) channelReference:(NSString*)channelName bridge:(Bridge*)bridge methods:(NSArray*)methods;
+ (BridgeRemoteObject*) serviceReference:(NSString*)serviceName bridge:(Bridge*)bridge methods:(NSArray*)methods;
+ (BridgeRemoteObject*) clientReference:(NSString*)objectName bridge:(Bridge*)bridge methods:(NSArray*)methods;

+ (BridgeRemoteObject*) referenceFromArray:(NSArray*) array bridge:(Bridge*)bridge methods:(NSArray*)methods;
+ (BridgeRemoteObject*) referenceFromCopyOfReference: (BridgeRemoteObject*) reference bridge:(Bridge*)bridge methods:(NSArray*)methods;
+ (BridgeRemoteObject*) referenceWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName bridge:(Bridge*)bridge methods:(NSArray*) methods;

@end
