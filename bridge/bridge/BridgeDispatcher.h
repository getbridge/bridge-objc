//
//  MyClass.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeReference;
@class BridgeService;

@interface BridgeDispatcher : NSObject {
  NSMutableDictionary* services;
  NSString* clientId;
}

@property(nonatomic, copy) NSString* clientId;

-(BridgeReference*) registerExistingService:(NSString*)oldName withName:(NSString*)name;
-(BridgeReference*) registerService:(BridgeService*)service withName:(NSString*)name;
-(BridgeReference*) registerRandomlyNamedService:(BridgeService*)service;
-(void) executeUsingReference:(BridgeReference*)reference withArguments:(NSArray*) arguments;

@end
