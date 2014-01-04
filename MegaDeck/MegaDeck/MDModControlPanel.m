//
//  MDModControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/20/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDModControlPanel.h"
#import "MDAppDelegate.h"

@implementation MDModControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		synth = [[MDAppDelegate sharedAppDelegate] synth];
		
		vibratoRateSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:0]];
		[self addSubview:vibratoRateSlider];
		[vibratoRateSlider setReverse:YES];
		[vibratoRateSlider setTaper:reverseAudio];
		[vibratoRateSlider setLabelText:@"VIBRATO RATE"];
		[vibratoRateSlider setDelegate:self];
		
		vibratoDepthSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:1]];
		[self addSubview:vibratoDepthSlider];
		[vibratoDepthSlider setLabelText:@"VIBRATO DEPTH"];
		[vibratoDepthSlider setLabelOffText:@"VIBRATO OFF"];
		[vibratoDepthSlider setOffValue:0];
		[vibratoDepthSlider setDelegate:self];
		
		portamentoSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:portamentoSlider];
		[portamentoSlider setLabelText:@"PORTAMENTO RATE"];
		[portamentoSlider setLabelOffText:@"PORTAMENTO OFF"];
		[portamentoSlider setOffValue:1.f];
		[portamentoSlider setDelegate:self];
    }
    return self;
}

- (float) getValue:(MDControl *)control
{	
	if( control == vibratoRateSlider )
	{
		return [synth vibratoPeriod];
	}
	else if( control == vibratoDepthSlider )
	{
		return [synth vibratoDepth];
	}
	else if( control == portamentoSlider )
	{
		return [synth portamentoRate];
	}

	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	float value = [(MDControlSlider*)control value];
	
	if( control == vibratoRateSlider )
	{
		[synth setVibratoPeriod:value];
	}
	else if( control == vibratoDepthSlider )
	{
		[synth setVibratoDepth:value];
	}
	else if( control == portamentoSlider )
	{
		[synth setPortamentoRate:value];
	}
}

- (void)dealloc 
{
    [vibratoRateSlider release];
	[vibratoDepthSlider release];
	[portamentoSlider release];
	
    [super dealloc];
}

@end