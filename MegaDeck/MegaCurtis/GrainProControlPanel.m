//
//  GrainProControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/27/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainProControlPanel.h"

@implementation GrainProControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{		
		textBox = [[MDTextBox alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:textBox];
		[textBox setLabelText:
		 @"You like?\n"
		 @"The paid version of MegaCurtis adds:\n\n"
		 @"_ MIDI INPUT \n"
		 @"_ PERFORMANCE RECORDING \n"
		 @"_ MODAL SCALES \n"
		 @"_ LOW-PASS FILTER \n"
		 @"_ ECHO \n"
		 @"_ POSITION MODULATION \n"
		 @"_ POSITION JITTER \n"
		 @"_ WAVE KEYBOARD MODE \n"
		 @"_ GRAIN JITTER \n"
		 @"_ GRAIN OVERLAP CONTROL \n\n"
		 @"and more! \n"
		 ];
		
		buyButton = [[self putButtonInSlot:4 withTitle:@"→ BUY" selector:@selector(touchBuy)] retain];
    }
    return self;
}

- (void) touchBuy
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/MegaCurtis"]];
}

- (void)dealloc 
{
	[buyButton release];
    [super dealloc];
}

@end
