//
//  objcsampleAppDelegate.h
//  objcsample
//
//  Created by Sridatta Thatipamala on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "bridge.h"

@class objcsampleViewController;

@interface objcsampleAppDelegate : NSObject <UIApplicationDelegate> {
  Bridge* bridge;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet objcsampleViewController *viewController;

@end
