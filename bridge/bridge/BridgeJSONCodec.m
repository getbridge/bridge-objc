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

+ (NSString *)constructConnectMessage {
  return [self constructConnectMessageWithId:NULL secret:NULL];
}


+ (NSString*) constructConnectMessageWithId:(NSString *)sessionId secret:(NSString *)secret {
  NSMutableDictionary* root = [NSMutableDictionary dictionary];
  [root setValue:@"CONNECT" forKey:@"command"];
  
  NSMutableDictionary* dataObject = [NSMutableDictionary dictionary];
  
  [dataObject setObject:[NSNull null] forKey:@"sessionid"];
  [dataObject setObject:[NSNull null] forKey:@"secret"];
  
  if(sessionId != NULL && secret != NULL) {
    [dataObject setObject:sessionId forKey:@"sessionid"];
    [dataObject setObject:secret forKey:@"secret"];
  }
  
  [root setObject:dataObject forKey:@"data"];
  
  [self typifyObject:root];
  
  return [root JSONString];
}

+ (NSArray*) typifyObject:(NSObject *)root
{
  NSArray* rtn = [NSArray array];
  
  if([root isKindOfClass:[NSDictionary class]]){
    
  } else if ([root isKindOfClass:[NSArray class]]) {
    
  } else if ([root isKindOfClass:[NSString class]]) {
    
  } else if ([root isKindOfClass:[NSNumber class]]){
    
  } else if ([root isKindOfClass:[NSNull class]]) {
    
  }
  
  return rtn;
}

@end
