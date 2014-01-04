//
//  MDSoundPlayer.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/29/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDSoundPlayer.h"

static OSStatus renderInput(
							void *inRefCon, 
							AudioUnitRenderActionFlags *ioActionFlags, 
							const AudioTimeStamp *inTimeStamp, 
							UInt32 inBusNumber, 
							UInt32 inNumberFrames, 
							AudioBufferList *ioData)
{	
	PlaybackStruct *sound = (PlaybackStruct*)inRefCon;
	
	AudioBuffer buffer = ioData->mBuffers[0];
	UInt32 *renderBuffer = (UInt32 *)buffer.mData;
	
	if( sound->isPlaying && *sound->isReady )
	{	
		UInt32 *sourceBuffer = (UInt32 *)sound->audioBuffer->mData;
		UInt32 start = *sound->start;
		UInt32 end = *sound->start + *sound->length;

		for( int i=0; i<inNumberFrames; i++ )
		{		
			renderBuffer[i] = sourceBuffer[sound->position++];
			if( sound->position >= end || sound->position < start) 
				sound->position = start;
		}
	}
	else
	{
		// render silence
		memset(renderBuffer, 0, inNumberFrames * sizeof(UInt32));
	}
	
    return noErr;
}

// --------------------------------------------------------------------------------
#pragma mark -

@implementation MDSoundPlayer

@synthesize renderCallback, soundModel;

- (id)initWithModel:(MDSoundModel*)model
{
    self = [self init];
    if (self) 
	{
		[self setSoundModel:model];
	}
	return self;
}

- (id)init 
{
    self = [super init];
    if (self) 
	{
		sound = (PlaybackStruct*)calloc(1, sizeof(PlaybackStruct));
		
		renderCallback.inputProc = renderInput;
		renderCallback.inputProcRefCon = sound;
		
		// register for sound file loaded notifications
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self 
		 selector:@selector(soundDidLoad) 
		 name:FILE_LOADED object:nil];
    }
    return self;
}

- (void) dealloc
{
	[soundModel release];
	free(sound);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

// ----------------------------------------------------------------------- soundModel
#pragma mark - soundModel

- (void) refreshModel
{
	NSLog(@"Player :: refreshModel");
	
	sound->audioBuffer	= [soundModel audioBuffer];
	sound->start		= [soundModel startPtr];
	sound->length		= [soundModel lengthPtr];
	sound->position		= 0;
	sound->isReady		= [soundModel isReadyPtr];
}

- (void) soundDidLoad
{
	[self refreshModel];
}

- (void) setSoundModel:(MDSoundModel*)model
{
	[soundModel release];
	soundModel = [model retain];
	[self refreshModel];
}

// ----------------------------------------------------------------------- control
#pragma mark - control

- (BOOL) isPlaying
{
	return sound->isPlaying;
}

- (void) setIsPlaying:(BOOL)isPlaying
{
	sound->isPlaying = soundModel ? isPlaying : NO;
}

- (void) play
{
	[self setIsPlaying:YES];
}

- (void) stop
{
	[self setIsPlaying:NO];
}

- (float) positionFraction
{
	return (float)sound->position / [soundModel frameCount];
}

@end
