//
//  BridgeRemoteObject.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "bridge.h"
#import "BridgeRemoteObject.h"


@implementation BridgeRemoteObject
@synthesize routingPrefix=routingPrefix_, routingId=routingId_, serviceName=serviceName_, methodName=methodName_, methods=methods_, bridge=bridge_;

-(void) dealloc
{
  [self setRoutingPrefix:nil];
  [self setRoutingId:nil];
  [self setServiceName:nil];
  [self setMethodName:nil];
    
  [self setBridge:nil];
  [self setMethods:nil];
  
  [super dealloc];
}

/*
 @brief Construct a reference explicitly. Internal only.
 @param routingPrefix Type of reference - "client", "channel" or "named" service
 @param routingId Identifier used to route this reference
 @param serviceName Identifier used to dereference this reference
 @param methodName The method this reference refers to. Can be nil
 */
- (id)initWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName bridge:(Bridge*) bridge methods:(NSArray*) methods
{
    self = [super init];
    if (self) {
        // Initialization code here.
      [self setRoutingPrefix:routingPrefix];
      [self setRoutingId:routingId];
      [self setServiceName:serviceName];
      [self setMethodName:methodName];
      [self setMethods:methods];
      [self setBridge:bridge];
    }
    
    return self;
}

/*
 @brief Get a representation of this reference for JSON encoding. Internal only.
 @return An NSDictionary* that represents the pathchain of this reference.
 */
- (NSDictionary*) dictionaryFromReference 
{
  NSObject* theId = self.routingId;
  if(theId == nil) {
    theId = [NSNull null];
  }
  NSArray* ref = [NSArray arrayWithObjects:self.routingPrefix, theId, self.serviceName, self.methodName, nil];
  return [NSDictionary dictionaryWithObjectsAndKeys:ref, @"ref", self.methods, @"operations", nil];
}


/*
 @brief Get method signature for a selector this reference responds to. Internal only.
 @param selector an Objective-C selector
 @return A dummy method signature that is not used anywhere
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  // This is complete BS. We just need to return something to please ObjC runtime
  NSString* selectorString = NSStringFromSelector(selector);
  NSMutableString* signatureString = [NSMutableString stringWithString:@"@^v^c"];
  
  NSUInteger length = [selectorString length];
  NSRange range = NSMakeRange(0, length);
  while(range.location != NSNotFound)
  {
    range = [selectorString rangeOfString:@":" options:0 range:range];
    if(range.location != NSNotFound)
    {
      range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
      [signatureString appendString:@"^v"];
    }
  }
  
  return [NSMethodSignature signatureWithObjCTypes:[signatureString UTF8String]];
}

/*
 @brief Handle an invocation that cannot be handled by a method
 This method takes the invocation and sends it down the wire using Bridge
 */
- (void) forwardInvocation:(NSInvocation *)anInvocation
{
  NSString* selectorString = NSStringFromSelector([anInvocation selector]);
  NSString* methName = selectorString; // True for 0 args methods
  
  // number of colons in selector = number of args. ghettotastic but it should work
  NSUInteger argsCount = 0, length = [selectorString length];
  NSRange range = NSMakeRange(0, length); 
  while(range.location != NSNotFound)
  {
    range = [selectorString rangeOfString: @":" options:0 range:range];
    if(range.location != NSNotFound)
    {
      if(argsCount == 0){
        methName = [selectorString substringToIndex:range.location];
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
  
  BridgeRemoteObject* destination = [BridgeRemoteObject referenceFromCopyOfReference:self];
  [destination setMethodName:methName];
  
  [self.bridge _sendWithDestination:destination andArgs:args];
}

-(NSString*) description
{
  return [NSString stringWithFormat:@"{BridgeRemoteObject: [%@, %@, %@, %@]}", self.routingPrefix, self.routingId, self.serviceName, self.methodName];
}

+ (BridgeRemoteObject*) channelReference:(NSString*)channelName bridge:(Bridge*)bridge methods:(NSArray*)methods
{
  NSString* prefixedChannelName = [NSString stringWithFormat:@"channel:%@", channelName];
  return [BridgeRemoteObject referenceWithRoutingPrefix:@"channel" 
                             andRoutingId:channelName 
                             andServiceName:prefixedChannelName 
                             andMethodName:nil 
                             bridge:bridge 
                             methods:methods];
}

+ (BridgeRemoteObject*) serviceReference:(NSString*)serviceName bridge:(Bridge*)bridge methods:(NSArray*)methods
{
  return [BridgeRemoteObject referenceWithRoutingPrefix:@"named"
                                           andRoutingId:serviceName
                                           andServiceName:serviceName
                                           andMethodName:nil 
                                           bridge:bridge
                                           methods:methods];
}

+ (BridgeRemoteObject*) clientReference:(NSString*)objectName bridge:(Bridge*)bridge methods:(NSArray*)methods
{
    return [BridgeRemoteObject referenceWithRoutingPrefix:@"named"
                                           andRoutingId:[bridge clientId]
                                           andServiceName:objectName
                                           andMethodName:nil 
                                           bridge:bridge
                                           methods:methods];
}

/*
 @brief Construct an autoreleased reference from a 3 or 4 element array
 Each part of the array maps to the following in order of occurence: routingPrefix, routingId,
 serviceName and (optionally) methodName
 @param array An NSArray* whose elements represent the parts of a reference
 @return A Bridge reference
 */
+ (BridgeRemoteObject*) referenceFromArray:(NSArray*) array bridge:(Bridge*)bridge methods:(NSArray*)methods {
  
  NSString* routingPrefix = [array objectAtIndex:0];
  NSString* routingId = [array objectAtIndex:1];
  NSString* serviceName = [array objectAtIndex:2];
  NSString* methodName = nil;
  
  if([array count] == 4){
    methodName = [array objectAtIndex:3];
  }
  
  return [BridgeRemoteObject referenceWithRoutingPrefix:routingPrefix
                                           andRoutingId:routingId
                                           andServiceName:serviceName 
                                           andMethodName:methodName 
                                           bridge:bridge
                                           methods:methods];
}


/*
 @brief Construct an autoreleased reference from an existing reference
 This method is most often used to duplicate a 3-part reference and add a methodName to it
 @param array An BridgeRemoteObject to clone
 @return A Bridge reference whose parts are the same as the argument
 */
+ (BridgeRemoteObject*) referenceFromCopyOfReference: (BridgeRemoteObject*) reference 
{
 
  return [BridgeRemoteObject referenceWithRoutingPrefix:reference.routingPrefix 
                                         andRoutingId:reference.routingId
                                         andServiceName:reference.serviceName 
                                         andMethodName:reference.methodName 
                                         bridge:reference.bridge
                                         methods:reference.methods];
}

/*
 @brief Construct an autoreleased BridgeRemoteObject
 */
+ (BridgeRemoteObject*)referenceWithRoutingPrefix:(NSString*)routingPrefix andRoutingId:(NSString*)routingId andServiceName:(NSString*)serviceName andMethodName:(NSString*)methodName bridge:(Bridge*)bridge methods:(NSArray*)methods
{
  return [[[BridgeRemoteObject alloc] initWithRoutingPrefix:routingPrefix 
                                               andRoutingId:routingId
                                               andServiceName:serviceName 
                                               andMethodName:methodName 
                                               bridge:bridge 
                                               methods:methods] autorelease];
}

@end
