//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeDispatcher.h"

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
  
  NSMutableString* selectorString = [NSMutableString stringWithString:[reference methodName]];
  
  for(int argIdx = 0, argLength = [arguments count]; argIdx < argLength; argIdx++){
    // Stupid cross-compatibility hack. Keyword arguments would be a great fix
    [selectorString appendString:@":"];
  }
  
  SEL selector = NSSelectorFromString(selectorString);
  NSMethodSignature* signature = [service methodSignatureForSelector:selector];
  
  if(signature != nil){
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:service];
    
    for(int argIdx = 0, argLength = [arguments count]; argIdx < argLength; argIdx++){
      id arg = [arguments objectAtIndex:argIdx];
      [invocation setArgument:&arg atIndex:argIdx+2];
    }
    
    [invocation invoke];
  }
}

@end
