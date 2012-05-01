//
//  BridgeSocketBuffer.m
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeSocketBuffer.h"
#import "BridgeSocket.h"

@implementation BridgeSocketBuffer

- (id)init
{
    self = [super init];
    if (self) {
      queue = [NSMutableArray new];
    }
    
    return self;
}

- (void) send:(NSData*) data
{
  NSString* messageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [queue insertObject:messageString atIndex:0];
}

-(void)processQueueIntoSocket:(id<BridgeSocket>)socket withClientId:(NSString *)anId
{
  for(int i = [queue count] - 1; i >= 0 ; i--)
  {
    NSString* messageString = [queue objectAtIndex:i];
    NSString* replacementString = [NSString stringWithFormat:@"client, %@", anId];
    NSString* replacedString = [messageString stringByReplacingOccurrencesOfString:@"\"client\",null/" withString:replacementString];
    [socket send:[replacedString dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  [queue release];
  queue = [NSMutableArray new];
  
}

@end
