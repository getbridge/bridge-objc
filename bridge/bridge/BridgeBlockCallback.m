//
//  BridgeBlockCallback.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/7/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeBlockCallback.h"

@implementation BridgeBlockCallback

- (id)initWithBlock:(bridge_block) block
{
    self = [super init];
    if (self) {
        // Initialization code here.
      _block = [block copy];
    }
    
    return self;
}

-(void) dealloc
{
  [_block release];
  [super dealloc];
}

-(void) callback:(NSArray*)array {
  _block(array);
}

@end
