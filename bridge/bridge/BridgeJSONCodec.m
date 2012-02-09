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
  return [bridgeRequestString objectFromJSONString];
}

+ (NSData*) constructConnectMessage 
{
  return [self constructConnectMessageWithId:NULL secret:NULL];
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

+ (NSData*) constructConnectMessageWithId:(NSString *)sessionId secret:(NSString *)secret {
  NSMutableDictionary* root = [NSMutableDictionary dictionary];
  [root setValue:@"CONNECT" forKey:@"command"];
  
  NSMutableDictionary* dataObject = [NSMutableDictionary dictionary];
  NSNumber* zero = [NSNumber numberWithInt:0];
  NSMutableArray* session = [NSMutableArray arrayWithObjects:zero, zero, nil];
    
  if(sessionId != NULL && secret != NULL) {
    [session replaceObjectAtIndex:0 withObject:session];
    [session replaceObjectAtIndex:1 withObject:secret];
  }
  
  [dataObject setObject:session forKey:@"session"];
  
  [root setObject:dataObject forKey:@"data"];
    
  return [root JSONData];
}

@end
