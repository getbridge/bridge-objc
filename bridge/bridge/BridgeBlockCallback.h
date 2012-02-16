//
//  BridgeBlockCallback.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeService.h"

@interface BridgeBlockCallback : BridgeService {
  void (^ _block)(NSArray*);
}

-(id) initWithBlock:(bridge_block) block;
-(void) callback;

@end
