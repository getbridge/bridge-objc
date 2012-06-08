//
//  MyClass.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeRemoteObject, Bridge;

@interface BridgeSystemService : NSObject {
  Bridge* bridge;
}

-(id)initWithBridge:(Bridge*)bridge;
-(void) hookChannelHandler:(NSString*)channeName :(BridgeRemoteObject*)handler;
-(void) hookChannelHandler:(NSString*)channeName :(BridgeRemoteObject*)handler :(BridgeRemoteObject*)callback;

@end
