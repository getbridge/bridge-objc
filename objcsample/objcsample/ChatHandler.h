//
//  ChatHandler.h
//  objcsample
//
//  Created by Sridatta Thatipamala on 2/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeService.h"

@interface ChatHandler : BridgeService

-(void) msg:(NSString*)sender :(NSString*)message;

@end
