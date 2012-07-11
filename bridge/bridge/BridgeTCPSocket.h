//
//  BridgeTCPSocket.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BridgeConnection, GCDAsyncSocket;
@protocol BridgeSocket;

@interface BridgeTCPSocket : NSObject <BridgeSocket>
{
}

-(id)initWithConnection:(BridgeConnection*)aConnection isSecure:(BOOL)secure;

@end
