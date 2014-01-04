//
//  MegaSliceAppDelegate.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDAppDelegate.h"
#import "SliceController.h"
#import "LayerViewController.h"

#define LAYERS	8

@interface MegaLayerAppDelegate : MDAppDelegate
{
	SliceController	*sliceController;
	LayerViewController *layerViewController;
}

- (void) editSourceModel:(MDSoundModel*)model;

@end
