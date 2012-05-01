//
//  MyClass.h
//  bridge
//
//  Created by Sridatta Thatipamala on 2/8/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeReference, Bridge;

@interface BridgeSystemService : NSObject {
  Bridge* bridge;
}

-(id)initWithBridge:(Bridge*)bridge;
-(void) hook_channel_handler:(NSString*)channeName :(BridgeReference*)handler;
-(void) hook_channel_handler:(NSString*)channeName :(BridgeReference*)handler :(BridgeReference*)callback;

@end
