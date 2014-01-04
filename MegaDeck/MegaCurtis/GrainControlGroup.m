//
//  GrainControlGroup.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/20/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainControlGroup.h"
#import "MegaCurtisAppDelegate.h"

@implementation GrainControlGroup

- (id)initWithPanel:(MDControlPanel *)_panel
{
    self = [super initWithPanel:_panel];
    if (self) 
	{
		synth = (GrainSynthController*)[[MegaCurtisAppDelegate sharedAppDelegate] synth];
		
		sizeJitter = [[MDControlSlider alloc] initWithFrame:[panel nextSlotRect]];
		[panel addSubview:sizeJitter];
		[sizeJitter setLabelText:@"PITCH JITTER"];
		[sizeJitter setTaper:audio];
		[sizeJitter setDelegate:self];
		
		overlap = [[MDControlSlider alloc] initWithFrame:[panel nextSlotRect]];
		[panel addSubview:overlap];
		[overlap setLabelText:@"OVERLAP"];
		[overlap setTaper:audio];
		[overlap setDelegate:self];
		
		overlapModRate = [[MDControlSlider alloc] initWithFrame:[panel nextSlotRect]];
		[panel addSubview:overlapModRate];
		[overlapModRate setLabelText:@"OVERLAP LFO RATE"];
		[overlapModRate setReverse:YES];
		[overlapModRate setTaper:reverseAudio];
		[overlapModRate setDelegate:self];	
		
		overlapModDepth = [[MDControlSlider alloc] initWithFrame:[panel nextSlotRect]];
		[panel addSubview:overlapModDepth];
		[overlapModDepth setLabelText:@"OVERLAP LFO DEPTH"];
		[overlapModDepth setLabelOffText:@"OVERLAP LFO OFF"];
		[overlapModDepth setOffValue:0];
		[overlapModDepth setTaper:audio];
		[overlapModDepth setDelegate:self];
    }
    return self;
}

- (float) getValue:(MDControl *)control
{
	if( control == sizeJitter )
	{
		return [synth grainSizeJitter];
	}
	else if( control == overlapModRate )
	{
		return [synth overlapModPeriod];
	}
	else if( control == overlapModDepth )
	{
		return [synth overlapModDepth];
	}
	else if( control == overlap )
	{
		return [synth overlap];
	}
	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	float value = [(MDControlSlider*)control value];
	NSLog(@"value:%f",value);
	
	if( control == sizeJitter )
	{
		[synth setGrainSizeJitter:value];
	}
	else if( control == overlapModRate )
	{
		[synth setOverlapModPeriod:value];
	}
	else if( control == overlapModDepth )
	{
		[synth setOverlapModDepth:value];
	}
	else if( control == overlap )
	{
		[synth setOverlap:value];
	}
}

- (void)dealloc 
{
    [sizeJitter release];
	[overlapModRate release];	
	[overlapModDepth release];
	[overlap release];
    [super dealloc];
}

@end
