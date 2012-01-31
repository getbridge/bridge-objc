//
//  bridge.h
//  bridge
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface bridge : NSObject {
  
@private
  GCDAsyncSocket* sock;
  NSString* host;
  int port;
}

-(id) initWithHost:(NSString*)hostName andPort:(int) port;
-(void) connect;

@end
