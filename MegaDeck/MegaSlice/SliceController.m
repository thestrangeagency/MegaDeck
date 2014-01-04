//
//  SliceController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceController.h"
#import "SliceLoopModel.h"
#import "TSACoreGraph.h"
#import "TSACoreGraph+Mixer.h"
#import "MathUtil.h"

@implementation SliceController

@synthesize loops;

- (id) initWithVoiceCount:(int)nVoices
{
	self = [super init];
    if (self) 
	{
		NSLog(@"SliceController init");
		
		loops = [[NSMutableArray arrayWithCapacity:nVoices] retain];
		for(int i=0; i<nVoices; i++)
		{
			SliceLoopModel *loop = [[SliceLoopModel alloc] init];
			[loop setKeyAndReload:[NSString stringWithFormat:@"LOOP_%i",i]];
			[[loop soundModel] setRecordPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"REC_%i.WAV",i]]];
			[loops addObject:loop];
		}
        
		[self unsolo];
		
#if TARGET_NAME == MegaSlice
		NSLog(@"target: MegaSlice");
		[self setXFade:0];
#elif TARGET_NAME == MegaLayer
		NSLog(@"target: MegaLayer");
		[self mute:2];
		[self mute:3];
		[self mute:4];
		[self mute:5];
		[self mute:6];
		[self mute:7];
#endif
		
    }
    return self;
}

- (int) voiceCount
{
	return [loops count];
}

- (void) attachToGraph:(id<TSAGraphProtocol>)graph
{
	UInt32 numbuses = [self voiceCount];
	
	AudioStreamBasicDescription clientFormat;
    clientFormat.mSampleRate		= 44100.0f;	
	clientFormat.mFormatID			= kAudioFormatLinearPCM;
	clientFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	clientFormat.mFramesPerPacket	= 1;
	clientFormat.mChannelsPerFrame	= 2;
	clientFormat.mBitsPerChannel	= 16;
	clientFormat.mBytesPerPacket	= 4;
	clientFormat.mBytesPerFrame		= 4;
	
	for (int i = 0; i < numbuses; ++i) 
	{
		[(TSACoreGraph*)graph 
		 addGeneratorMixerBusCallback:[(SliceLoopModel*)[loops objectAtIndex:i] renderCallback] 
		 inputFormat:clientFormat];
	}
}

- (void) setLevel:(float)level forLoop:(int)index
{
	[[self loop:index] setGain:level];
}

- (float) levelForLoop:(int)index
{
	return [[self loop:index] gain];
}

- (void) mute:(int)index
{
	[[self loop:index] setIsMuted:YES];
}

- (void) unmute:(int)index
{
	[[self loop:index] setIsMuted:NO];
}

- (BOOL) isMuted:(int)index
{
	return [[self loop:index] isMuted];
}

- (NSString*) lastPath:(int)index
{
	return [[self loop:index] lastPath];
}

- (void) solo:(int)index
{
	[self unsolo];
	int i = 0;
	for( SliceLoopModel *loop in loops )
	{
		// store mute state
		if( [loop isMuted] ) soloMask |= 1 << i;
		i++;
		[loop setIsMuted:YES];
	}
	[[self loop:index] setIsMuted:NO];
	soloIndex = index;
}

- (void) unsolo
{
	int i = 0;
	if( soloIndex >= 0 )
		for( SliceLoopModel *loop in loops )
		{
			if( soloMask & (1 << i) )
			{
				// was muted before solo
			}
			else
			{
				[loop setIsMuted:NO];
			}
			i++;
		}
	soloMask = 0;
	soloIndex = -1;
}

- (BOOL) isSolo:(int)index
{
	return soloIndex == index;
}

- (void) setXFade:(float)xFade
{
	[[self loop:1] setGain:lin2log(xFade)];
	[[self loop:0] setGain:lin2log(1.f - xFade)];
}

- (SliceLoopModel*)loop:(int)index
{
	return [loops objectAtIndex:index];
}

- (void)dealloc 
{
    [loops release];
    [super dealloc];
}

@end
