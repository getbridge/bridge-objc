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

- (NSArray*) dictionaryFromReference {
  NSArray* ref = [NSArray arrayWithObjects:routingPrefix, routingId, serviceName, methodName, nil];
  return [NSDictionary dictionaryWithObject:ref forKey:@"ref"];
}

+ (BridgeReference*) referenceFromArray:(NSArray*) array {
  NSString* routingPrefix = [array objectAtIndex:0];
  NSString* routingId = [array objectAtIndex:1];
  NSString* serviceName = [array objectAtIndex:2];
  NSString* methodName = [array objectAtIndex:3];
  
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
