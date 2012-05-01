//
//  BridgeSocket.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BridgeSocket <NSObject>

-(void) send:(NSData*)data;

@end
