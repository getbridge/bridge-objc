//
//  main.m
//  channels
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
-(void)join:(NSString *)channelName :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback;
-(void) joinWriteable:(NSString*)channelName :(NSString*)secretWord :(BridgeRemoteObject*)chatObj :(BridgeRemoteObject*)callback;

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

-(void)join:(NSString *)channelName :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback
{
  NSLog(@"HELLO");
  [bridge joinChannel:channelName withHandler:chatObj isWriteable:NO andCallback:callback];
  
}

-(void)joinWriteable:(NSString *)channelName :(NSString *)secretWord :(BridgeRemoteObject *)chatObj :(BridgeRemoteObject *)callback
{
  if([secretWord isEqualToString:@"secret123"])
  {
    [bridge joinChannel:channelName withHandler:chatObj isWriteable:YES andCallback:callback];
  }
}

@end

int main (int argc, const char * argv[])
{
  
  @autoreleasepool {
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], @"secure",
                             @"localhost", @"host",
                             [NSNumber numberWithInt:8093], @"port"
                             , nil];
    Bridge* bridge = [[Bridge alloc] initWithAPIKey:@"abcdefgh" andDelegate:nil options:options];
    [bridge publishService:@"auth" withHandler:[[AuthObj alloc] initWithBridge:bridge]];
    [bridge connect];
    
    [[NSRunLoop currentRunLoop] run];
    dispatch_main();
  }
  
  return 0;
}