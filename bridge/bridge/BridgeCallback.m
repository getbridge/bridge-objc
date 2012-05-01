//
//  BridgeBlockCallback.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/7/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeCallback.h"

@implementation BridgeCallback

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

-(void) callback:(NSArray*)args {
  _block(args);
}

+(BridgeCallback*) callbackWithBlock:(bridge_block)block
{
  return [[[BridgeCallback alloc] initWithBlock:block] autorelease];
}

@end
