//
//  BridgeBlockCallback.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/7/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeObject.h"

typedef void(^bridge_block)(NSArray*);

@interface BridgeCallback : NSObject <BridgeObject>  {
  bridge_block _block;
}

-(id) initWithBlock:(bridge_block)block;
-(void) callback:(NSArray*)args;

+(BridgeCallback*) callbackWithBlock:(bridge_block)block;

@end
