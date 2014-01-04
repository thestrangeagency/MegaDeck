//
//  MegaStokeAppDelegate.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDAppDelegate.h"
#import "StokeController.h"
#import "StokeSequencer.h"
#import "StokeViewController.h"

#undef  MD_SHARE_MESSAGE
#define MD_SHARE_MESSAGE	@"Check out this strange sound I made with MegaStoke!"

#define N_VOICES	4

@interface MegaStokeAppDelegate : MDAppDelegate
{
	StokeController *stokeController;
	StokeSequencer *stokeSequencer;
	StokeViewController *stokeViewController;
}

@property (readonly) StokeController *stokeController;

- (void) editSourceModel:(MDSoundModel*)model;
- (void) selectChannel:(int)channel;

@end
