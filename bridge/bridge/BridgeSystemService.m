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

@implementation BridgeSystemService

- (id)initWithBridge:(Bridge*) aBridge
{
    self = [super init];
    if (self) {
      bridge = aBridge;
    }
    
    return self;
}

-(void) hook_channel_handler:(NSString*)channeName :(BridgeRemoteObject*)handler
{
  [self hook_channel_handler:channeName :handler :nil];
}

/*
 @brief Takes a local, anonymous reference and rebinds it to the given channel name. Calls a success callback
*/
-(void) hook_channel_handler:(NSString*)channelName :(BridgeRemoteObject*)handler :(id)callback {
  
  BridgeRemoteObject* chanRef = [bridge.dispatcher storeExistingObject:[handler serviceName] withKey:[NSString stringWithFormat:@"channel:%@", channelName]];
  [chanRef setRoutingPrefix:@"channel"];
  [chanRef setRoutingId:channelName];
  
  [callback callback:channelName :chanRef];
}

/*
 @brief Retrieves all instance methods of a given BridgeService and passes to callback
*/
-(void) getservice:(NSString*)serviceName :(BridgeRemoteObject*)callback
{
  NSObject* object = [bridge.dispatcher getObjectWithName:serviceName];
  NSArray* methods = [BridgeUtils getMethods:object];
  
  [callback callback:methods];
}

/*
 @brief Call bridgeDidErrorWithMessage on delegate when error occurs
*/
-(void) remoteError:(NSString*)msg
{
  [bridge _onError:msg];
}

@end
