//
//  GrainKeyControlGroup.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/24/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainKeyControlGroup.h"

@implementation GrainKeyControlGroup

@synthesize controller;

- (id)initWithPanel:(MDControlPanel *)_panel
{
	self = [super initWithPanel:_panel];
    if (self) 
	{
		waveKeysButton = [[_panel putButtonInSlot:0 withTitle:@"WAVE" selector:nil] retain];
		// override frame
		CGRect frame = waveKeysButton.frame;
		frame.origin.x += 48;
		[waveKeysButton setFrame:frame];
		// override selector so it doesn't target the panel
		[waveKeysButton addTarget:self action:@selector(touchWave) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (void) setController:(GrainSynthViewController *)_controller
{
	controller = _controller;
	waveKeysButton.selected = !controller.portraitOrientation;
}

- (void) touchWave
{
	waveKeysButton.selected = !waveKeysButton.selected;
	[controller setPortraitOrientation:!waveKeysButton.selected];
}

- (void) dealloc
{
	[waveKeysButton release];
	[controller release];
	[super dealloc];
}

@end
