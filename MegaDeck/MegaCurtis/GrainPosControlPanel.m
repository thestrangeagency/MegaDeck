//
//  GrainPosControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/26/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainPosControlPanel.h"
#import "MegaCurtisAppDelegate.h"

@implementation GrainPosControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		synth = (GrainSynthController*)[[MegaCurtisAppDelegate sharedAppDelegate] synth];
		
		startJitter = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:startJitter];
		[startJitter setLabelText:@"POSITION JITTER"];
		[startJitter setTaper:linear];
		[startJitter setDelegate:self];
		
		startModRate = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:startModRate];
		[startModRate setLabelText:@"POSITION LFO RATE"];
		[startModRate setReverse:YES];
		[startModRate setTaper:reverseAudio];
		[startModRate setDelegate:self];	
		
		startModDepth = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:startModDepth];
		[startModDepth setLabelText:@"POSITION LFO DEPTH"];
		[startModDepth setLabelOffText:@"POSITION LFO OFF"];
		[startModDepth setOffValue:0];
		[startModDepth setTaper:audio];
		[startModDepth setDelegate:self];
		
		startSlewSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:startSlewSlider];
		[startSlewSlider setLabelText:@"POSITION SLEW RATE"];
		[startSlewSlider setLabelOffText:@"POSITION SLEW OFF"];
		[startSlewSlider setOffValue:1];
		[startSlewSlider setDelegate:self];
    }
    return self;
}

- (float) getValue:(MDControl *)control
{
	if( control == startJitter )
	{
		return [synth grainStartJitter];
	}
	else if( control == startModRate )
	{
		return [synth startModPeriod];
	}
	else if( control == startModDepth )
	{
		return [synth startModDepth];
	}
	else if( control == startSlewSlider )
	{
		return [synth startSlewRate];
	}
	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	float value = [(MDControlSlider*)control value];
	NSLog(@"value:%f",value);
	
	if( control == startJitter )
	{
		[synth setGrainStartJitter:value];
	}
	else if( control == startModRate )
	{
		[synth setStartModPeriod:value];
	}
	else if( control == startModDepth )
	{
		[synth setStartModDepth:value];
	}
	else if( control == startSlewSlider )
	{
		[synth setStartSlewRate:value];
	}
}

- (void)dealloc 
{
	[startJitter release];
	[startModRate release];
	[startModDepth release];
	[startSlewSlider release];
    [super dealloc];
}

@end
