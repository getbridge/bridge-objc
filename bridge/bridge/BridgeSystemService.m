//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeService.h"
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

/*
 @brief Takes a local, anonymous reference and rebinds it to the given channel name. Calls a success callback
*/
-(void) hook_channel_handler:(NSString*)channelName :(BridgeReference*)handler :(id)callback {
  BridgeReference* chanRef = [dispatcher registerExistingService:[handler serviceName] withName:channelName];
  [chanRef setRoutingId:@"channel"];
  [chanRef setServiceName:channelName];
  [callback callback:channelName :chanRef];
}

/*
 @brief Retrieves all instance methods of a given BridgeService and passes to callback
*/
-(void) getservice:(NSString*)serviceName :(BridgeReference*)callback
{
  BridgeService* service = [dispatcher getService:serviceName];
  NSArray* methods = [service getMethods];
  
  [callback callback:methods];
}

/*
 @brief Call bridgeDidErrorWithMessage on delegate when error occurs
*/
-(void) remoteError:(NSString*)msg
{
  if([delegate respondsToSelector:@selector(bridgeDidErrorWithMessage:)]){
    [delegate bridgeDidErrorWithMessage:delegate];
  }
}

@end
