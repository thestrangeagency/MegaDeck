//
//  MegaSpaceAppDelegate.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDAppDelegate.h"
#import "SpaceSynthViewController.h"

@interface MegaSpaceAppDelegate : MDAppDelegate

@property (retain) UIWindow *secondWindow;
@property (retain) SpaceSynthViewController *spaceViewVontroller;

- (void) setupScreenConnectionNotificationHandlers;
- (void) checkForExistingScreenAndInitializeIfPresent;

@end
