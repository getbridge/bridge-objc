//
//  MyClass.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeSystemService.h"

@implementation BridgeSystemService

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) hook_channel_handler:(NSString*)foo :(id)bar :(id)baz {
  NSLog(@"System service works");
}

@end
