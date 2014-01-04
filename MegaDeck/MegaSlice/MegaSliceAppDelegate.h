//
//  MegaSliceAppDelegate.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDAppDelegate.h"
#import "SliceController.h"
#import "SliceViewController.h"

@interface MegaSliceAppDelegate : MDAppDelegate
{
	SliceController	*sliceController;
	SliceViewController *sliceViewController;
}

- (void) editSourceModel:(MDSoundModel*)model;

@end
