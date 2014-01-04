//
//  MDMixControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDMixControlPanel.h"
#import "MDAppDelegate.h"

@implementation MDMixControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		mMixer = [[[MDAppDelegate sharedAppDelegate] graph] mMixer];
		mCompressor = [[[MDAppDelegate sharedAppDelegate] graph] mCompressor];
		synth = [[MDAppDelegate sharedAppDelegate] synth];
		
		volumeSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:volumeSlider];
		[volumeSlider setLabelText:@"VOLUME"];
		[volumeSlider setTaper:audio];
		[volumeSlider setDelegate:self];
		
		squashSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:squashSlider];
		[squashSlider setLabelText:@"BOOST"];
		[squashSlider setDelegate:self];
		
		tremoloRateSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:tremoloRateSlider];
		[tremoloRateSlider setReverse:YES];
		[tremoloRateSlider setTaper:reverseAudio];
		[tremoloRateSlider setLabelText:@"TREMOLO RATE"];
		[tremoloRateSlider setDelegate:self];
		
		tremoloDepthSlider = [[MDControlSlider alloc] initWithFrame:[self nextSlotRect]];
		[self addSubview:tremoloDepthSlider];
		[tremoloDepthSlider setLabelText:@"TREMOLO DEPTH"];
		[tremoloDepthSlider setLabelOffText:@"TREMOLO OFF"];
		[tremoloDepthSlider setOffValue:0];
		[tremoloDepthSlider setDelegate:self];	
    }
    return self;
}

- (void) hideTremolo
{
	[tremoloRateSlider removeFromSuperview];
	[tremoloDepthSlider removeFromSuperview];
}

- (float) getValue:(MDControl *)control
{
	AudioUnitParameterValue value = 0.0f;
	
	if( control == volumeSlider )
	{
		// volume
		AudioUnitGetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, &value);
		return (float)value;
	}
	else if( control == squashSlider )
	{
		// squash
		AudioUnitGetParameter(mCompressor, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, &value);
		return (float)value / -20.f;
	}
	else if( control == tremoloRateSlider )
	{
		return [synth tremoloPeriod];
	}
	else if( control == tremoloDepthSlider )
	{
		return [synth tremoloDepth];
	}
	return 0;
}

- (void) valueChanged:(MDControl *)control
{
	AudioUnitParameterValue value = (AudioUnitParameterValue)[(MDControlSlider*)control value];
	NSLog(@"value:%f",value);
	
	if( control == volumeSlider )
	{
		// volume
		AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, value, 0);
	}
	else if( control == squashSlider )
	{
		// squash
		AudioUnitParameterValue param = value * -20.f;
		AudioUnitSetParameter(mCompressor, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, param, 0);
		param = value * 16;
		AudioUnitSetParameter(mCompressor, kDynamicsProcessorParam_ExpansionRatio, kAudioUnitScope_Global, 0, param, 0);
		param = value * 20;
		AudioUnitSetParameter(mCompressor, kDynamicsProcessorParam_MasterGain, kAudioUnitScope_Global, 0, param, 0);
	}
	else if( control == tremoloRateSlider )
	{
		[synth setTremoloPeriod:value];
	}
	else if( control == tremoloDepthSlider )
	{
		[synth setTremoloDepth:value];
	}
}

- (void)dealloc 
{
    [volumeSlider release];
	[squashSlider release];
	[tremoloRateSlider release];
	[tremoloDepthSlider release];
	
    [super dealloc];
}

@end
