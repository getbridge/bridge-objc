//
//  BridgeUtils.h
//  bridge
//
//  Created by Sridatta Thatipamala on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BridgeUtils : NSObject

+ (NSString*) generateRandomId;
+ (NSArray*) getMethods:(NSObject*)anObject;

@end
