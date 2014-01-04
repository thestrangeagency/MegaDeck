//
//  MDEnvelopeControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/15/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDEnvelopeControlPanel.h"
#import "MDAppDelegate.h"

@implementation MDEnvelopeControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		synth = [[MDAppDelegate sharedAppDelegate] synth];
		
		attackSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:0]];
		[self addSubview:attackSlider];
		[attackSlider setLabelText:@"ATTACK"];
		[attackSlider setDelegate:self];
		
		decaySlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:1]];
		[self addSubview:decaySlider];
		[decaySlider setLabelText:@"DECAY"];
		[decaySlider setDelegate:self];		
		
		sustainSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:2]];
		[self addSubview:sustainSlider];
		[sustainSlider setLabelText:@"SUSTAIN"];
		[sustainSlider setTaper:audio];
		[sustainSlider setDelegate:self];
		
		releaseSlider = [[MDControlSlider alloc] initWithFrame:[self rectForSlot:3]];
		[self addSubview:releaseSlider];
		[releaseSlider setLabelText:@"RELEASE"];
		[releaseSlider setDelegate:self];
		
		holdButton = [[self putButtonInSlot:4 withTitle:@"HOLD" selector:@selector(touchHold)] retain];
		[holdButton setSelected:[synth ampHold]];
    }
    return self;
}

- (void) touchHold
{
	[synth setAmpHold:[synth ampHold] ? NO : YES];
	[holdButton setSelected:[synth ampHold]];
	
	float alpha = [synth ampHold] ? .5 : 1.f;
	
	[UIView animateWithDuration:.5
					 animations:^{
						 [attackSlider setAlpha:alpha];
						 [decaySlider setAlpha:alpha];
						 [sustainSlider setAlpha:alpha];
						 [releaseSlider setAlpha:alpha];
					 }];
}

- (float) getValue:(MDControl *)control
{	
	if( control == attackSlider )
	{
		return [synth ampAttack];
	}
	else if( control == decaySlider )
	{
		return [synth ampDecay];
	}
	else if( control == sustainSlider )
	{
		return [synth ampSustain];
	}
	else if( control == releaseSlider )
	{
		return [synth ampRelease];
	}
	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	float value = [(MDControlSlider*)control value];
	
	if( control == attackSlider )
	{
		[synth setAmpAttack:value];
	}
	else if( control == decaySlider )
	{
		[synth setAmpDecay:value];
	}
	else if( control == sustainSlider )
	{
		[synth setAmpSustain:value];
	}
	else if( control == releaseSlider )
	{
		[synth setAmpRelease:value];
	}
}

- (void)dealloc 
{
    [attackSlider release];
	[decaySlider release];
	[sustainSlider release];
	[releaseSlider release];
	[holdButton release];
    [super dealloc];
}

@end