//
//  BridgeService.m
//  bridge
//
//  Created by Sridatta Thatipamala on 2/6/12.
//  Copyright 2012 Flotype Inc. All rights reserved.
//
#import <objc/runtime.h>

#import "BridgeService.h"
#import "BridgeBlockCallback.h"

@implementation BridgeService

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSArray*) getMethods
{
  
  Method *methods;
  unsigned int methodCount;
  if ((methods = class_copyMethodList([self class], &methodCount)))
  {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:methodCount];
    
    while (methodCount--){
      NSString* methodString = [NSString stringWithCString: sel_getName(method_getName(methods[methodCount])) encoding: NSASCIIStringEncoding];
      NSString* cleanedString = [methodString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@":"]];
      
      if (![cleanedString isEqualToString:@"dealloc"] && ![cleanedString hasPrefix:@"init"]) {
        [results addObject:cleanedString];
      }
    }
    
    free(methods);	
    return results;
  }
  return nil;
}

+(BridgeService*) serviceWithBlock:(bridge_block) block {
  return [[BridgeBlockCallback alloc] initWithBlock:block];
}


@end
