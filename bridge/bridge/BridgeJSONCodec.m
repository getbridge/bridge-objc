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
#import "BridgeReference.h"
#import "BridgeService.h"

@implementation BridgeJSONCodec

/*
  @brief Take a string from the connection and parse as JSON, traversing the structure for references
  This method parses JSON and passes the given references pointer to decodeReferences
  @param bridgeRequestString A JSON string
  @param references A pointer to an NSArray pointer
 */
+ (NSDictionary*) parseRequestString:(NSString*)bridgeRequestString withReferenceArray:(NSArray**) references
{
  (*references) = [NSMutableArray array];
  return [BridgeJSONCodec decodeReferencesInObject:[bridgeRequestString objectFromJSONString] withReferenceArray:(*references)];
}

/*
 @brief Constructs a command message of type "JOINWORKERPOOL" according to the Bridge specification 
 @param workerpool Name of worker pool to join
*/
+ (NSData*) constructJoinMessageWithWorkerpool:(NSString *)workerpool
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: workerpool, @"name", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINWORKERPOOL", @"command", data, @"data", nil];
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "JOINCHANNEL" according to the Bridge specification 
 @param channel Name of channel to join
 */
+ (NSData*) constructJoinMessageWithChannel:(NSString *)channel handler:(BridgeReference *)handler callback:(BridgeReference *)callback
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: channel, @"name", [handler dictionaryFromReference], @"handler", [callback dictionaryFromReference], @"callback", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINCHANNEL", @"command", data, @"data", nil];
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "CONNECT" according to the Bridge specification 
 */
+ (NSData*) constructConnectMessage 
{
  return [self constructConnectMessageWithId:nil secret:nil];
}

+ (NSData*) constructConnectMessageWithId:(NSString *)sessionId secret:(NSString *)secret {
  NSMutableDictionary* root = [NSMutableDictionary dictionary];
  [root setValue:@"CONNECT" forKey:@"command"];
  
  NSMutableDictionary* dataObject = [NSMutableDictionary dictionary];
  
  NSNull* null = [NSNull null];
  NSMutableArray* session = [NSMutableArray arrayWithObjects:null, null, nil];
    
  if(sessionId != nil && secret != nil) {
    [session replaceObjectAtIndex:0 withObject:session];
    [session replaceObjectAtIndex:1 withObject:secret];
  }
  
  [dataObject setObject:session forKey:@"session"];
  
  [root setObject:dataObject forKey:@"data"];
    
  return [root JSONData];
}

/*
 @brief Constructs a command message of type "SEND" according to the Bridge specification
 Creates the appropriate JSON structure and calls encodeReferences method on the arguments
 @param destination A four-part destination references that points to a remote method
 @param args Arguments to the remote procedure call
 @param dispatcher The Bridge object's dispatcher with which to register any BridgeService objects that are encountered
*/
+ (NSData*) constructSendMessageWithDestination:(BridgeReference *)destination andArgs:(NSArray *)args withDispatcher:(BridgeDispatcher *)dispatcher
{
  
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", args, @"args", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"SEND", @"command", data, @"data", nil];
  
  NSDictionary* encodedRoot = [BridgeJSONCodec encodeReferencesInObject:root withDispatcher:dispatcher];
  return [encodedRoot JSONData];
}

/*
 Traverses the structure for BridgeService objects and replaces them with BridgeReference objects.
 All BridgeService objects are registered with the provided dispatcher
*/
+ (id) encodeReferencesInObject:(id)object withDispatcher:(BridgeDispatcher *)dispatcher
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec encodeReferencesInObject:oldValue withDispatcher:dispatcher] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec encodeReferencesInObject:oldValue withDispatcher:dispatcher]];
    }
    return res;
  } else if ([object isKindOfClass:[BridgeReference class]]){
    return [((BridgeReference*) object) dictionaryFromReference];
  } else if ([object isKindOfClass:[BridgeService class]]) {
    BridgeReference* ref = [dispatcher registerRandomlyNamedService:object];
    NSArray* methods = [((BridgeService*) object) getMethods];
    [ref setMethods:methods];
    return [self encodeReferencesInObject:ref withDispatcher:dispatcher];
  } else {
    // Leaf node
    return object;
  }
}

/*
 Traverses the structure for any objects and replaces any objects of format '{ref:[Array]}'with a BridgeReference. These references are also inserted
 into an array the caller provides
*/
+ (id) decodeReferencesInObject:(id)object withReferenceArray:(NSMutableArray*) references
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    NSArray* ref;
    if(nil != (ref = [result objectForKey:@"ref"])) {
      // This is a reference
      BridgeReference* reference = [BridgeReference referenceFromArray:ref];
      [reference setMethods:[result objectForKey:@"operations"]];
      [references addObject:reference];
      return reference;
    }
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec decodeReferencesInObject:oldValue withReferenceArray:references] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec decodeReferencesInObject:oldValue withReferenceArray:references]];
    }
    return res;
  } else {
    // Leaf node
    return object;
  }
}

@end
