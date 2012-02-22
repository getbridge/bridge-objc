//
//  BridgeReference.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeReference.h"

@implementation BridgeReference
@synthesize routingPrefix, routingId, serviceName, methodName, methods;

/*
 @brief Construct a reference explicitly. Internal only.
 @param routingPrefix Type of reference - "client", "channel" or "named" service
 @param routingId Identifier used to route this reference
 @param serviceName Identifier used to dereference this reference
 @param methodName The method this reference refers to. Can be nil
 */
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

-(void) dealloc
{
  [self setRoutingPrefix:nil];
  [self setRoutingId:nil];
  [self setServiceName:nil];
  [self setMethodName:nil];
  
  [super dealloc];
}

/*
 @brief Set the bridge instance for this reference to use for SENDs. Internal only.
 @param bridge The Bridge instances that created this reference
 */
- (void) setBridge:(Bridge*) bridge
{
  _bridge = bridge; // No retaining or anything. This is a ref to a grandparent
}

/*
 @brief Get a representation of this reference for JSON encoding. Internal only.
 @return An NSDictionary* that represents the pathchain of this reference.
 */
- (NSDictionary*) dictionaryFromReference 
{
  NSArray* ref = [NSArray arrayWithObjects:routingPrefix, routingId, serviceName, methodName, nil];
  return [NSDictionary dictionaryWithObjectsAndKeys:ref, @"ref", methods, @"operations", nil];
}


/*
 @brief Get method signature for a selector this reference responds to. Internal only.
 @param selector an Objective-C selector
 @return A dummy method signature that is not used anywhere
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  // This is complete BS. We just need to return something to please ObjC runtime
  return [NSMethodSignature signatureWithObjCTypes:"@^v^c^v^v^v^v^v^v^v"];
}

/*
 @brief Handle an invocation that cannot be handled by a method
 This method takes the invocation and sends it down the wire using Bridge
 */
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

-(NSString*) description
{
  return [NSString stringWithFormat:@"{BridgeReference: [%@, %@, %@, %@]}", routingPrefix, routingId, serviceName, methodName];
}

/*
 @brief Construct an autoreleased reference from a 3 or 4 element array
 Each part of the array maps to the following in order of occurence: routingPrefix, routingId,
 serviceName and (optionally) methodName
 @param array An NSArray* whose elements represent the parts of a reference
 @return A Bridge reference
 */
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

/*
 @brief Construct an autoreleased reference from an existing reference
 This method is most often used to duplicate a 3-part reference and add a methodName to it
 @param array An BridgeReference to clone
 @return A Bridge reference whose parts are the same as the argument
 */
+ (BridgeReference*) referenceFromCopyOfReference: (BridgeReference*) reference{
  NSString* routingPrefix = [reference routingPrefix];
  NSString* routingId = [reference routingId];
  NSString* serviceName = [reference serviceName];
  NSString* methodName = [reference methodName];
  
  return [BridgeReference referenceWithRoutingPrefix:routingPrefix andRoutingId:routingId
                                      andServiceName:serviceName andMethodName:methodName];
}

/*
 @brief Construct an autoreleased BridgeReference
 */
+ (BridgeReference*)referenceWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName
{
  return [[[BridgeReference alloc] initWithRoutingPrefix:routingPrefix andRoutingId:routingId andServiceName:serviceName andMethodName:methodName] autorelease];
}

@end
