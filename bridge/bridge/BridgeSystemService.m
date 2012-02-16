//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeSystemService.h"
#import "BridgeReference.h"
#import "BridgeDispatcher.h"

@implementation BridgeSystemService

- (id)initWithDispatcher:(BridgeDispatcher *)disp andDelegate:(id)del
{
    self = [super init];
    if (self) {
      dispatcher = disp;
      delegate = del;
    }
    
    return self;
}

-(void) hook_channel_handler:(NSString*)channelName :(BridgeReference*)handler :(id)callback {
  BridgeReference* chanRef = [dispatcher registerExistingService:[handler serviceName] withName:channelName];
  [chanRef setRoutingId:@"channel"];
  [chanRef setServiceName:channelName];
  [callback callback:channelName :chanRef];
}

-(void) remoteError:(NSString*)msg
{
  if([delegate respondsToSelector:@selector(bridgeDidErrorWithMessage:)]){
    [delegate bridgeDidErrorWithMessage:delegate];
  }
}

@end
