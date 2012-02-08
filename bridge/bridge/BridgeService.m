//
//  BridgeService.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeService.h"
#import "BridgeBlockCallback.h"

@implementation BridgeService

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(BridgeService*) serviceWithBlock:(bridge_block) block {
  return [[BridgeBlockCallback alloc] initWithBlock:block];
}


@end
