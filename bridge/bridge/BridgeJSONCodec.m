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

+ (NSDictionary*) parseRequestString:(NSString*)bridgeRequestString
{
  return [BridgeJSONCodec replaceReferencesInObject:[bridgeRequestString objectFromJSONString]];
}

+ (NSData*) constructMessageWithWorkerpool:(NSString *)workerpool
{
  NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: workerpool, @"name", nil];
  NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:@"JOINWORKERPOOL", @"command", data, @"data", nil];
  return [root JSONData];
}

+ (NSData*) constructMessageWithChannel:(NSString *)channel handler:(BridgeReference *)handler callback:(BridgeReference *)callback
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

+ (id) replaceReferencesInObject:(id)object
{
  if([object isKindOfClass:[NSDictionary class]]){
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:object];
    
    NSArray* ref;
    if(nil != (ref = [result objectForKey:@"ref"])) {
      // This is a reference
      return [BridgeReference referenceFromArray:ref];
    }
    
    // Just a regular dictionary
    NSArray* keys = [result allKeys];
    for(int keysIdx = 0; keysIdx < [keys count]; keysIdx++){
      NSString* key = [keys objectAtIndex:keysIdx];
      id oldValue = [result objectForKey:key];
      [result setObject:[BridgeJSONCodec replaceReferencesInObject:oldValue] forKey:key];
    }
    return result;
    
  } else if ([object isKindOfClass:[NSArray class]]){
    NSMutableArray* res = [NSMutableArray arrayWithArray:object];
    
    for(int arrayIdx = 0; arrayIdx < [res count]; arrayIdx++){
      id oldValue = [res objectAtIndex:arrayIdx];
      [res replaceObjectAtIndex:arrayIdx withObject:[BridgeJSONCodec replaceReferencesInObject:oldValue]];
    }
    return res;
  } else {
    // Leaf node
    return object;
  }
}

@end
