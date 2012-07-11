//
//  BridgeSocketBuffer.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BridgeSocket;

@interface BridgeSocketBuffer : NSObject<BridgeSocket> {
}


-(void)processQueueIntoSocket:(id<BridgeSocket>)socket withClientId:(NSString*)anId;

@end
