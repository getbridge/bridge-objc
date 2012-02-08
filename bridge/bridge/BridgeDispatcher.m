//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeDispatcher.h"

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
  NSString* randomString = @"IAMRANDOM";
  return [self registerService:service withName:randomString];
}

-(void) executeUsingReference:(BridgeReference*)reference withArguments:(NSArray*) arguments
{
  BridgeService* service = [services objectForKey:[reference serviceName]];
  
  NSMutableString* selectorString = [NSMutableString stringWithString:[reference methodName]];
  for(int argIdx = 0; argIdx < [arguments count]; argIdx++){
    // Stupid cross-compatibility hack. Keyword arguments would be a great fix
    [selectorString appendString:@":"];
  }
  
  SEL selector = NSSelectorFromString(selectorString);
  NSMethodSignature* signature = [service methodSignatureForSelector:selector];
}

@end
