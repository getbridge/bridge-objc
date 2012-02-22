//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeDispatcher.h"
#import "BridgeReference.h"
#import "BridgeService.h"
#import "BridgeBlockCallback.h"

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation BridgeDispatcher

@synthesize clientId;

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
    services = [[NSMutableDictionary dictionary] retain];
  }
  
  return self;
}

-(void) dealloc
{
  [services release];
  [super dealloc];
}

-(BridgeReference*) registerExistingService:(NSString*)oldName withName:(NSString*)name {
  return [self registerService:[services objectForKey:oldName] withName:name];
}

-(BridgeReference*) registerService:(BridgeService*)service withName:(NSString*)name
{
  [services setObject:service forKey:name];
  return [BridgeReference referenceWithRoutingPrefix:@"client" andRoutingId:clientId andServiceName:name andMethodName:nil];
}

-(BridgeReference*) registerRandomlyNamedService:(BridgeService*)service
{
  NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
  
  for (int i=0; i<10; i++) {
    [randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
  }
  
  return [self registerService:service withName:randomString];
}

-(void) executeUsingReference:(BridgeReference*)reference withArguments:(NSArray*) arguments
{
  BridgeService* service = [services objectForKey:[reference serviceName]];
  BOOL isCallback = [service isKindOfClass:[BridgeBlockCallback class]];
  
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

@end
