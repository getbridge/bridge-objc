//
//  main.m
//  chat-server
//
//  Created by Sridatta Thatipamala on 7/11/12.
//  Copyright (c) 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bridge-mac/bridge.h"

@interface AuthObj : NSObject <BridgeObject> {
  Bridge* bridge;
}

-(id) initWithBridge:(Bridge*)theBridge;
-(void) login:(NSString*)name :(NSString*)password :(NSString*)room :(BridgeRemoteObject*)chatObj :(BridgeRemoteObject*)callback;

@end

@implementation AuthObj

- (id)initWithBridge:(Bridge *)theBridge
{
  self = [super init];
  if (self) {
    // Initialization code here.
    bridge = theBridge;
  }
  
  return self;
}

-(void)login:(NSString *)name :(NSString *)password :(NSString *)room :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback
{
  if([password isEqualToString:@"secret123"])
  {
    [bridge joinChannel:room withHandler:chatObj andCallback:callback];
    NSLog(@"Welcome!");
  } 
  else {
    NSLog(@"Sorry!");
  }
}

@end

int main (int argc, const char * argv[])
{
  
  @autoreleasepool {
    Bridge* bridge = [[Bridge alloc] initWithApiKey:@"myprivkey"];
    [bridge publishService:@"auth" withHandler:[[AuthObj alloc] init]];
    [bridge connect];
    
    [[NSRunLoop currentRunLoop] run];
    dispatch_main();
  } 
  
  return 0;
}

