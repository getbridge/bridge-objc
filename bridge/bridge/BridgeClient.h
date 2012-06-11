//
//  BridgeClient.h
//  bridge
//
//  Created by Sridatta Thatipamala on 6/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

@class Bridge, BridgeRemoteObject;

@interface BridgeClient : NSObject {
  @private
  Bridge* bridge;
  NSString* clientId;
}

-(id) initWithBridge:(Bridge*) bridge clientId:(NSString*)aClientId;
-(BridgeRemoteObject*) getService:(NSString*)serviceName;

@end
