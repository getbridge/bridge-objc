//
//  BridgeBlockCallback.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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

-(void) callback:(NSArray*)array {
  _block(array);
}

@end
