//
//  BrJSONCodec.m
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeJSONCodec.h"
#import "JSONKit.h"

@implementation BridgeJSONCodec

+ (NSDictionary*) parseRequestString:(NSString*)bridgeRequestString withReferenceArray:(NSArray**) references
{
  (*references) = [NSMutableArray array];
  return [BridgeJSONCodec decodeReferencesInObject:[bridgeRequestString objectFromJSONString] withReferenceArray:(*references)];
}

+ (NSData*) constructJoinMessageWithWorkerpool:(NSString *)workerpool
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: workerpool, @"name", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINWORKERPOOL", @"command", data, @"data", nil];
  return [root JSONData];
}

+ (NSData*) constructJoinMessageWithChannel:(NSString *)channel handler:(BridgeReference *)handler callback:(BridgeReference *)callback
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: channel, @"name", [handler dictionaryFromReference], @"handler", [callback dictionaryFromReference], @"callback", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINCHANNEL", @"command", data, @"data", nil];
  return [root JSONData];
}

+ (NSData*) constructConnectMessage 
{
  return [self constructConnectMessageWithId:nil secret:nil];
}

+ (NSData*) constructConnectMessageWithId:(NSString *)sessionId secret:(NSString *)secret {
  NSMutableDictionary* root = [NSMutableDictionary dictionary];
  [root setValue:@"CONNECT" forKey:@"command"];
  
  NSMutableDictionary* dataObject = [NSMutableDictionary dictionary];
  NSNumber* zero = [NSNumber numberWithInt:0];
  NSMutableArray* session = [NSMutableArray arrayWithObjects:zero, zero, nil];
    
  if(sessionId != nil && secret != nil) {
    [session replaceObjectAtIndex:0 withObject:session];
    [session replaceObjectAtIndex:1 withObject:secret];
  }
  
  [dataObject setObject:session forKey:@"session"];
  
  [root setObject:dataObject forKey:@"data"];
    
  return [root JSONData];
}

+ (NSData*) constructSendMessageWithDestination:(BridgeReference *)destination andArgs:(NSArray *)args withReferenceArray:(NSArray **)references
{
  (*references) = [NSMutableArray array];
  
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", args, @"args", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"SEND", @"command", data, @"data", nil];
  
  NSDictionary* encodedRoot = [BridgeJSONCodec encodeReferencesInObject:root withReferenceArray:(*references)];
  return [encodedRoot JSONData];
}

+ (id) encodeReferencesInObject:(id)object withReferenceArray:(NSMutableArray*) references
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec encodeReferencesInObject:oldValue withReferenceArray:references] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec encodeReferencesInObject:oldValue withReferenceArray:references]];
    }
    return res;
  } else if ([object isKindOfClass:[BridgeReference class]]){
    return [((BridgeReference*) object) dictionaryFromReference];
  } else {
    // Leaf node
    return object;
  }
}

+ (id) decodeReferencesInObject:(id)object withReferenceArray:(NSMutableArray*) references
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    NSArray* ref;
    if(nil != (ref = [result objectForKey:@"ref"])) {
      // This is a reference
      BridgeReference* reference = [BridgeReference referenceFromArray:ref];
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
