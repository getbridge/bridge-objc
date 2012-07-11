//
//  BridgeSocketBuffer.m
//  bridge
//
//  Created by Sridatta Thatipamala on 4/28/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "BridgeSocketBuffer.h"
#import "BridgeSocket.h"

@interface BridgeSocketBuffer() {
  
}

@property(nonatomic, retain) NSMutableArray* queue;

@end

@implementation BridgeSocketBuffer

@synthesize queue;

-(void) dealloc {
  [self setQueue:nil];
  [super dealloc];
}

- (id)init
{
    self = [super init];
  
    if (self) {
      [self setQueue:[[NSMutableArray new] autorelease]];
    }
    
    return self;
}

- (void) send:(NSData*) data
{
  NSString* messageString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  [self.queue insertObject:messageString atIndex:0];
}

-(void)processQueueIntoSocket:(id<BridgeSocket>)socket withClientId:(NSString *)anId
{
  for(int i = [self.queue count] - 1; i >= 0 ; i--)
  {
    NSString* messageString = [self.queue objectAtIndex:i];
    NSString* replacementString = [NSString stringWithFormat:@"\"client\",\"%@\"", anId];
    NSString* replacedString = [messageString stringByReplacingOccurrencesOfString:@"\"client\",null" withString:replacementString];
    [socket send:[replacedString dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  [self setQueue:[[NSMutableArray new] autorelease]];
  
}

@end
