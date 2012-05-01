//
//  BridgeUtils.m
//  bridge
//
//  Created by Sridatta Thatipamala on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BridgeUtils.h"
#import <objc/runtime.h>

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation BridgeUtils

+(NSString*)generateRandomId
{
  NSMutableString* randomString = [NSMutableString stringWithCapacity: 10];
  
  for (int i=0; i<10; i++) {
    [randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
  }
  return randomString;
}

+ (NSArray*) getMethods:(NSObject*)anObject
{
  Method *methods;
  unsigned int methodCount;
  if ((methods = class_copyMethodList([anObject class], &methodCount)))
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

@end
