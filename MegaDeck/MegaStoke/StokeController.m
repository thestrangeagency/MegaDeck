//
//  StokeController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeController.h"
#import "StokeSynthController.h"
#import "MDSoundModel.h"
#import "StokeChannel.h"
#import "MDTransportModel.h"

@implementation StokeController

@synthesize sequence;

- (id) initWithVoiceCount:(int)nVoices
{
	self = [super init];
    if (self) 
	{
		sequence = [[StokeSequence alloc] initWithVoiceCount:nVoices];
		channels = [[NSMutableArray alloc] initWithCapacity:nVoices];
		
		for (int i=0; i<nVoices; i++)
		{
			// each channel is actually a single voiced synth
			StokeSynthController *synth = [[StokeSynthController alloc] initWithVoiceCount:1];
			[channels addObject:synth];
			[synth setSoundModel:[[sequence channelAtIndex:i] soundModel]];
			[synth setLoop:[[sequence channelAtIndex:i] loop]];
			[synth setAmpAttack:0];
			[synth setAmpSustain:1.f];
			[synth setAmpRelease:.1];
			[synth setOverlap:.4];
			[synth release];
		}
    }
    return self;
}

- (void) dealloc
{
	[channels removeAllObjects];
    [channels release];
	[sequence release];
    [super dealloc];
}

- (int) voiceCount
{
	return [channels count];
}

- (void) attachToGraph:(id<TSAGraphProtocol>)graph
{
	for (GrainSynthController *synth in channels) 
	{
		[synth attachToGraph:graph];
	}
}

- (TSASynthController*) synthForChannel:(int)channel
{
	return (TSASynthController*)[channels objectAtIndex:channel];
}

- (void)serialize
{
	[sequence serialize];
}

- (void)unserialize
{
	// pause playback
	[[MDTransportModel sharedMDTransportModel] stop];
	
	// load
	[sequence unserialize];
	int nVoices = [channels count];
	for (int i=0; i<nVoices; i++)
	{
		StokeSynthController *synth = [channels objectAtIndex:i];
		[synth setSoundModel:[[sequence channelAtIndex:i] soundModel]];
		[synth setLoop:[[sequence channelAtIndex:i] loop]];
	}
}

@end
