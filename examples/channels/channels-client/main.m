//
//  main.m
//  channels-client
//
//  Created by Sridatta Thatipamala on 7/11/12.
//  Copyright (c) 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bridge-mac/bridge.h"


#pragma mark Bridge Remote Objects
@protocol RemoteAuth <NSObject>
-(void)join:(NSString *)channelName :(NSObject<BridgeObject> *)chatObj :(NSObject<BridgeObject> *)callback;
-(void) joinWriteable:(NSString*)channelName :(NSString*)secretWord :(BridgeRemoteObject*)chatObj :(BridgeRemoteObject*)callback;
@end

@protocol RemoteChat <NSObject>
-(void)message:(NSString*)sender :(NSString*)msg;
@end

#pragma mark Bridge Objects
@interface ChatObj : NSObject <BridgeObject>
-(void)message:(NSString*)sender :(NSString*)msg;
@end

@implementation ChatObj

-(void)message:(NSString*)sender :(NSString*)msg
{
  NSLog(@"%@ : %@", sender, msg);
}

@end


#pragma mark Main Loop
int main (int argc, const char * argv[])
{
  
  @autoreleasepool {
    
    Bridge* bridge = [[Bridge alloc] initWithApiKey:@"mypubkey"];
    
    BridgeRemoteObject<RemoteAuth>* remoteAuth = (BridgeRemoteObject<RemoteAuth>*) [bridge getService:@"auth"];
    BridgeCallback* callback = [BridgeCallback callbackWithBlock:^(NSArray* args){
      // First argument is the name of the sender
      NSString* roomName = [args objectAtIndex:0];
      // Second argument is the message
      BridgeRemoteObject<RemoteChat>* channel = (BridgeRemoteObject<RemoteChat>*) [args objectAtIndex:1];
      
      NSLog(@"Joined channel: %@", roomName);
      [channel message:@"steve" :@"This should not work."]; 
    }];
    
    [remoteAuth join:@"bridge-lovers" :[ChatObj new] :callback];
    [bridge connect];
    
    [[NSRunLoop currentRunLoop] run];
    dispatch_main();
  }
  
  return 0;
}
