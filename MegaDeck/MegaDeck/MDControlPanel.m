//
//  MDControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControlPanel.h"

@implementation MDControlPanel

@synthesize nSlots;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self setBackgroundColor:[UIColor blackColor]];
		nSlots = 0;
    }
    return self;
}

- (CGRect) rectForSlot:(int)slot
{
	nSlots = MAX(slot+1, nSlots);
	return CGRectMake(40, (slot+1) * 48, 144, 40);
}

- (CGRect) btnRectForSlot:(int)slot
{
	nSlots = MAX(slot+1, nSlots);
	return CGRectMake(40, (slot+1) * 48, 40, 40);
}

- (CGRect) nextSlotRect
{
	return [self rectForSlot:nSlots];
}

- (void) valueChanged:(MDControl*)control
{
	// override	
}

- (float) getValue:(MDControl*)control
{
	// override
	return 0;
}

- (MDInverseButton*) putButtonInSlot:(int)slot withTitle:(NSString*)title selector:(SEL)selector
{
	MDInverseButton *button = [MDInverseButton buttonWithType:UIButtonTypeCustom];
	
	[button setFrame:[self btnRectForSlot:slot]];
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	
	[self addSubview:button];
	return button;
}

@end
