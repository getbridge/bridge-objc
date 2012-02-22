//
//  bridgeDispatcherTests.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/14/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "bridgeDispatcherTests.h"
#import "BridgeDispatcher.h"

@implementation bridgeDispatcherTests

- (void)testDispatcher {
  BridgeDispatcher* dispatcher = [[BridgeDispatcher alloc] init];
  
  BridgeService* dummyService = [BridgeService serviceWithBlock:^(NSObject* foo, ...){
    NSLog(@"HARRO");
  }];
  
  [dispatcher setClientId:@"CLIENTID"];
  
  BridgeReference* returnedRef = [dispatcher registerService:dummyService withName:@"someservice"];
  BridgeReference* ref = [BridgeReference referenceFromArray:[NSArray arrayWithObjects:@"client", @"CLIENTID", @"someservice", nil]];
  
  STAssertTrue([ref isEqualToReference:returnedRef], @"Reference returned by dispatcher is client.CLIENTID.SERVICENAME");
  
  BridgeReference* newReturnedRef = [dispatcher registerExistingService:@"someservice" asNewService:@"anotherservice"];
  BridgeReference* newRef = [BridgeReference referenceFromArray:[NSArray arrayWithObjects:@"client", @"CLIENTID", @"anotherservice", nil]];

  STAssertTrue([newRef isEqualToReference:newReturnedRef], @"Reference returned by dispatcher is client.CLIENTID.SERVICENAME");
    
  [dispatcher release];
}

@end
