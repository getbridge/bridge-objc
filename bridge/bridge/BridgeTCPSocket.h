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
  GCDAsyncSocket* sock;
  BridgeConnection* connection;
}

-(id)initWithConnection:(BridgeConnection*)aConnection;

@end
