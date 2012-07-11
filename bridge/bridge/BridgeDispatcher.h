//
//  MyClass.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bridge, BridgeRemoteObject;
@protocol BridgeObjectBase;

@interface BridgeDispatcher : NSObject {
}

-(id)initWithBridge:(Bridge*)aBridge;

-(BridgeRemoteObject*) storeExistingObject:(NSString*)oldName withKey:(NSString*)name;
-(BridgeRemoteObject*) storeObject:(NSObject <BridgeObjectBase> *)service withName:(NSString*)name;
-(BridgeRemoteObject*) storeRandomObject:(NSObject<BridgeObjectBase>*)service;
-(NSObject<BridgeObjectBase> *) getObjectWithName:(NSString*)name;
-(void) executeUsingReference:(BridgeRemoteObject *)reference withArguments:(NSArray*) arguments;

@end
