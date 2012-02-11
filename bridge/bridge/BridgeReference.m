//
//  BridgeReference.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeReference.h"

@implementation BridgeReference
@synthesize routingPrefix, routingId, serviceName, methodName;

- (id)initWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName
{
    self = [super init];
    if (self) {
        // Initialization code here.
      [self setRoutingPrefix:routingPrefix];
      [self setRoutingId:routingId];
      [self setServiceName:serviceName];
      [self setMethodName:methodName];
    }
    
    return self;
}

- (void) setBridge:(Bridge*) bridge
{
  _bridge = bridge; // No retaining or anything. This is a ref to a grandparent
}

- (NSArray*) dictionaryFromReference 
{
  NSArray* ref = [NSArray arrayWithObjects:routingPrefix, routingId, serviceName, methodName, nil];
  return [NSDictionary dictionaryWithObject:ref forKey:@"ref"];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  // This is complete BS. We just need to return something to please ObjC runtime
  return [NSMethodSignature signatureWithObjCTypes:"@^v^ci"];
}

- (void) forwardInvocation:(NSInvocation *)anInvocation
{
  NSString* selectorString = NSStringFromSelector([anInvocation selector]);
  NSString* methodName = selectorString; // True for 0 args methods
  
  // number of colons in selector = number of args. ghettotastic but it should work
  NSUInteger argsCount = 0, length = [selectorString length];
  NSRange range = NSMakeRange(0, length); 
  while(range.location != NSNotFound)
  {
    range = [selectorString rangeOfString: @":" options:0 range:range];
    if(range.location != NSNotFound)
    {
      if(argsCount == 0){
        methodName = [selectorString substringToIndex:range.location];
      }
      range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
      argsCount++; 
    }
  }
  
  // Transfer args from NSInvocation to NSArray. This and the above loop can be combined someday
  NSMutableArray* args = [NSMutableArray array];
  for(int argsIdx = 2; argsIdx < argsCount+2; argsIdx++){
    id theArg;
    [anInvocation getArgument:&theArg atIndex:argsIdx];
    [args addObject:theArg];
  }
  
  BridgeReference* destination = [BridgeReference referenceFromCopyOfReference:self];
  [destination setMethodName:methodName];
  
  [_bridge _sendMessageWithDestination:destination andArgs:args];
}

+ (BridgeReference*) referenceFromArray:(NSArray*) array {
  NSString* routingPrefix = [array objectAtIndex:0];
  NSString* routingId = [array objectAtIndex:1];
  NSString* serviceName = [array objectAtIndex:2];
  NSString* methodName = nil;
  if([array count] == 4){
     methodName = [array objectAtIndex:3];
  }
  
  return [BridgeReference referenceWithRoutingPrefix:routingPrefix andRoutingId:routingId
 andServiceName:serviceName andMethodName:methodName];
}

+ (BridgeReference*) referenceFromCopyOfReference: (BridgeReference*) reference{
  NSString* routingPrefix = [reference routingPrefix];
  NSString* routingId = [reference routingId];
  NSString* serviceName = [reference serviceName];
  NSString* methodName = [reference methodName];
  
  return [BridgeReference referenceWithRoutingPrefix:routingPrefix andRoutingId:routingId
                                      andServiceName:serviceName andMethodName:methodName];
}

+ (BridgeReference*)referenceWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName
{
  return [[[BridgeReference alloc] initWithRoutingPrefix:routingPrefix andRoutingId:routingId andServiceName:serviceName andMethodName:methodName] autorelease];
}

@end
