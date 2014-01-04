//
//  MDLowPassControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/14/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDFxControlPanel.h"
#import "MDAppDelegate.h"
#import "TSACoreGraph+Control.h"

@implementation MDFxControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		graph = [[MDAppDelegate sharedAppDelegate] graph];
		echo = [[MDAppDelegate sharedAppDelegate] echo];
		
		cutoffSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:0]];
		[self addSubview:cutoffSlider];
		[cutoffSlider setLabelText:@"CUTOFF"];
		[cutoffSlider setTaper:audio];
		[cutoffSlider setDelegate:self];
		
		resonanceSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:1]];
		[self addSubview:resonanceSlider];
		[resonanceSlider setLabelText:@"RESONANCE"];
		[resonanceSlider setReverse:YES];
		[resonanceSlider setTaper:reverseAudio];
		[resonanceSlider setDelegate:self];	
		
		delayLevelSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:2]];
		[self addSubview:delayLevelSlider];
		[delayLevelSlider setLabelText:@"ECHO LEVEL"];
		[delayLevelSlider setTaper:audio];
		[delayLevelSlider setDelegate:self];
		
		delayLengthSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:3]];
		[self addSubview:delayLengthSlider];
		[delayLengthSlider setLabelText:@"ECHO LENGTH"];
		[delayLengthSlider setDelegate:self];
    }
    return self;
}

- (float) getValue:(MDControl *)control
{	
	if( control == cutoffSlider )
	{
		return [graph filterCutoff];
	}
	else if( control == resonanceSlider )
	{
		return [graph filterResonance];
	}
	else if( control == delayLevelSlider )
	{
		return [echo delayLevel];
	}
	else if( control == delayLengthSlider )
	{
		return [echo delayLengthFraction];
	}
	
	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	float value = [(MDControlSlider*)control value];
	NSLog(@"value:%f",value);
	
	if( control == cutoffSlider )
	{
		[graph setFilterCutoff:value];
	}
	else if( control == resonanceSlider )
	{
		[graph setFilterResonance:value];
	}
	else if( control == delayLevelSlider )
	{
		[echo setDelayLevel:value];
	}
	else if( control == delayLengthSlider )
	{
		[echo setDelayLengthFraction:value];
	}
}

- (void)dealloc 
{
    [cutoffSlider release];
	[resonanceSlider release];
	[delayLevelSlider release];
	[delayLengthSlider release];
    [super dealloc];
}

@end
