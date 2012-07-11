//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeDispatcher.h"
#import "BridgeRemoteObject.h"
#import "BridgeObjectBase.h"
#import "BridgeCallback.h"
#import "BridgeUtils.h"

@interface BridgeDispatcher () {
  
}

@property(nonatomic, retain) NSMutableDictionary* services;
@property(nonatomic, assign) Bridge* bridge;

@end

@implementation BridgeDispatcher
  @synthesize services=services_, bridge=bridge_;

-(void) dealloc
{
  [self setServices:nil];
  [super dealloc];
}

- (id)initWithBridge:(Bridge*)aBridge
{
  self = [super init];
  if (self) {
    // Initialization code here.
    [self setServices:[NSMutableDictionary dictionary]];
    [self setBridge:aBridge];
  }
  
  return self;
}

-(void) executeUsingReference:(BridgeRemoteObject*)reference withArguments:(NSArray*) arguments
{
  NSObject<BridgeObjectBase>* service = [self.services objectForKey:[reference serviceName]];
  BOOL isCallback = [service isKindOfClass:[BridgeCallback class]];
  
  NSMutableString* selectorString = [NSMutableString stringWithString:[reference methodName]];
  
  if(!isCallback){
    for(int argIdx = 0, argLength = [arguments count]; argIdx < argLength; argIdx++){
      // Stupid cross-compatibility hack. Keyword arguments would be a great fix
      [selectorString appendString:@":"];
    }
  } else {
    [selectorString appendString:@":"];
  }
  
  SEL selector = NSSelectorFromString(selectorString);
  NSMethodSignature* signature = [service methodSignatureForSelector:selector];
    
  if(signature != nil){
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:service];
    
    if(isCallback){
      // Don't expand the arguments
      [invocation setArgument:&arguments atIndex:2];
    } else {
      for(int argIdx = 0, argLength = [arguments count]; argIdx < argLength; argIdx++){
        id arg = [arguments objectAtIndex:argIdx];
        [invocation setArgument:&arg atIndex:argIdx+2];
      }
    }
    
    [invocation invoke];
  }
}

-(BridgeRemoteObject*) storeObject:(NSObject <BridgeObjectBase> *)service withName:(NSString *)name
{
  if(service == nil) {
    return nil;
  }
    
  [self.services setObject:service forKey:name];
  return [BridgeRemoteObject clientReference:name bridge:self.bridge methods:[BridgeUtils getMethods:service]];
}

-(BridgeRemoteObject*) storeExistingObject:(NSString *)oldName withKey:(NSString *)name
{
  id obj = [self.services objectForKey:oldName];
  return [self storeObject:obj withName:name];
}

-(BridgeRemoteObject*) storeRandomObject:(NSObject <BridgeObjectBase> *)service
{
  NSString* randomString = [BridgeUtils generateRandomId];
  return [self storeObject:service withName:randomString];
}

-(NSObject<BridgeObjectBase> *) getObjectWithName:(NSString*)name
{
  return (NSObject<BridgeObjectBase> *) [self.services objectForKey:name];
}

@end
