//
//  BridgeClient.m
//  bridge
//
//  Created by Sridatta Thatipamala on 6/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "bridge.h"
#import "BridgeClient.h"
#import "BridgeRemoteObject.h"

@implementation BridgeClient

- (id)initWithBridge:(Bridge*) bridge clientId:(NSString *)aClientId
{
    self = [super init];
    if (self) {
        // Initialization code here.
      clientId = [aClientId copy];
    }
    
    return self;
}

-(BridgeRemoteObject*)getService:(NSString *)serviceName
{
  return [BridgeRemoteObject referenceWithRoutingPrefix:@"client" andRoutingId:clientId andServiceName:serviceName andMethodName:nil bridge:bridge methods:nil];
}

@end
