//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "bridge.h"
#import "BridgeSystemService.h"
#import "BridgeRemoteObject.h"
#import "BridgeDispatcher.h"
#import "BridgeUtils.h"

@interface BridgeSystemService () {
  
}

@property(nonatomic, assign) Bridge* bridge;

@end

@implementation BridgeSystemService

@synthesize bridge=bridge_;

- (id)initWithBridge:(Bridge*) aBridge
{
    self = [super init];
    if (self) {
      [self setBridge:aBridge];
    }
    
    return self;
}

-(void) hookChannelHandler:(NSString*)channelName :(BridgeRemoteObject*)handler
{
  [self hookChannelHandler:channelName :handler :nil];
}

/*
 @brief Takes a local, anonymous reference and rebinds it to the given channel name. Calls a success callback
*/
-(void) hookChannelHandler:(NSString*)channelName :(BridgeRemoteObject*)handler :(id)callback {
  
  BridgeRemoteObject* chanRef = [self.bridge.dispatcher storeExistingObject:[handler serviceName] withKey:[NSString stringWithFormat:@"channel:%@", channelName]];
  [chanRef setRoutingPrefix:@"channel"];
  [chanRef setRoutingId:channelName];
  
  [callback callback:channelName :chanRef];
}

/*
 @brief Retrieves all instance methods of a given BridgeService and passes to callback
*/
-(void) getService:(NSString*)serviceName :(BridgeRemoteObject*)callback
{
  [callback callback:[self.bridge.dispatcher getObjectWithName:serviceName] :serviceName];
}

/*
 @brief Call bridgeDidErrorWithMessage on delegate when error occurs
*/
-(void) remoteError:(NSString*)msg
{
  [self.bridge _onError:msg];
}

@end
