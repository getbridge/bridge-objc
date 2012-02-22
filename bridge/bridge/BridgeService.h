//
//  BridgeService.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^bridge_block)(NSArray*);

@interface BridgeService : NSObject

-(NSArray*) getMethods;
+(BridgeService*) serviceWithBlock:(bridge_block) block;

@end
