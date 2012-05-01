//
//  BrJSONCodec.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "JSONKit.h"

#import "BridgeJSONCodec.h"
#import "BridgeDispatcher.h"
#import "BridgeRemoteObject.h"
#import "bridge.h"
#import "BridgeObject.h"
#import "BridgeUtils.h"

@implementation BridgeJSONCodec

+(NSDictionary*) parseRedirector:(NSData *)data
{
  return [data objectFromJSONData];
}

/*
  @brief Take a string from the connection and parse as JSON, traversing the structure for references
  This method parses JSON and passes the given references pointer to decodeReferences
  @param bridgeRequestString A JSON string
  @param references A pointer to an NSArray pointer
 */
+ (NSDictionary*) parseRequestString:(NSString*)requestString bridge:(Bridge*)bridge
{
  return [BridgeJSONCodec decodeReferencesInObject:[requestString objectFromJSONString] bridge:bridge];
}

/*
 @brief Constructs a command message of type "JOINWORKERPOOL" according to the Bridge specification 
 @param workerpool Name of worker pool to join
*/
+(NSData*) createJWPWithPool:(NSString *)workerpool callback:(BridgeRemoteObject *)callback
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: workerpool, @"name", [callback dictionaryFromReference], @"callback", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINWORKERPOOL", @"command", data, @"data", nil];
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "GETCHANNEL" according to the Bridge specification 
 @param workerpool Name of worker pool to join
 */
+ (NSData*) createGETCHANNEL:(NSString *)channel
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: channel, @"name", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"GETCHANNEL", @"command", data, @"data", nil];
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "JOINCHANNEL" according to the Bridge specification 
 @param channel Name of channel to join
 */
+ (NSData*) createJCWithChannel:(NSString *)channel handler:(BridgeRemoteObject *)handler callback:(BridgeRemoteObject *)callback
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: channel, @"name", [handler dictionaryFromReference], @"handler", [callback dictionaryFromReference], @"callback", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINCHANNEL", @"command", data, @"data", nil];
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "CONNECT" according to the Bridge specification 
 */
+ (NSData*) createCONNECT
{
  return [self createCONNECTWithId:nil secret:nil apiKey:nil];
}

+ (NSData*) createCONNECTWithId:(NSString *)sessionId secret:(NSString *)secret apiKey:(NSString *)key
{
  NSMutableDictionary* root = [NSMutableDictionary dictionary];
  [root setValue:@"CONNECT" forKey:@"command"];
  
  NSMutableDictionary* dataObject = [NSMutableDictionary dictionary];
  
  NSNull* null = [NSNull null];
  NSMutableArray* sessionObj = [NSMutableArray arrayWithObjects:null, null, nil];
    
  if(sessionId != nil && secret != nil) {
    [sessionObj replaceObjectAtIndex:0 withObject:sessionId];
    [sessionObj replaceObjectAtIndex:1 withObject:secret];
  }
  
  [dataObject setObject:sessionObj forKey:@"session"];
  [dataObject setObject:key forKey:@"api_key"];
  
  [root setObject:dataObject forKey:@"data"];
  NSLog(@"%@", root);
    
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "SEND" according to the Bridge specification
 Creates the appropriate JSON structure and calls encodeReferences method on the arguments
 @param destination A four-part destination references that points to a remote method
 @param args Arguments to the remote procedure call
 @param dispatcher The Bridge object's dispatcher with which to register any BridgeService objects that are encountered
*/
+ (NSData*) createSENDWithDestination:(BridgeRemoteObject *)destination args:(NSArray *)args bridge:(Bridge*)bridge
{
  
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", args, @"args", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"SEND", @"command", data, @"data", nil];
  
  NSDictionary* encodedRoot = [BridgeJSONCodec encodeReferencesInObject:root bridge:bridge];
  return [encodedRoot JSONData];
}

/*
 Traverses the structure for BridgeService objects and replaces them with BridgeRemoteObject objects.
 All BridgeService objects are registered with the provided dispatcher
*/
+ (id) encodeReferencesInObject:(id)object bridge:(Bridge *)bridge
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec encodeReferencesInObject:oldValue bridge:bridge] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec encodeReferencesInObject:oldValue bridge:bridge]];
    }
    return res;
  } else if ([object isKindOfClass:[BridgeRemoteObject class]]){
    return [((BridgeRemoteObject*) object) dictionaryFromReference];
  } else if ([object conformsToProtocol:@protocol(BridgeObject)]) {
    BridgeRemoteObject* ref = [bridge.dispatcher storeRandomObject:object];
    [ref setMethods:[BridgeUtils getMethods:object]];
    return [BridgeJSONCodec encodeReferencesInObject:ref bridge:bridge];
  } else {
    // Leaf node
    return object;
  }
}

/*
 Traverses the structure for any objects and replaces any objects of format '{ref:[Array]}'with a BridgeRemoteObject. These references are also inserted
 into an array the caller provides
*/
+ (id) decodeReferencesInObject:(id)object bridge:(Bridge *)bridge
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    NSArray* ref;
    if(nil != (ref = [result objectForKey:@"ref"])) {
      // This is a reference
      BridgeRemoteObject* reference = [BridgeRemoteObject referenceFromArray:ref bridge:bridge methods:[result objectForKey:@"operations"]];
      return reference;
    }
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec decodeReferencesInObject:oldValue bridge:bridge] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec decodeReferencesInObject:oldValue bridge:bridge]];
    }
    return res;
  } else {
    // Leaf node
    return object;
  }
}

@end
