//
//  bridgeTests.m
//  bridgeTests
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//

#import "bridgeTests.h"
#import "bridge.h"

@implementation bridgeTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
  Bridge* bridge = [[Bridge alloc] initWithHost:@"localhost" andPort:8090 withDelegate:self];
  [bridge connect];
}

@end
