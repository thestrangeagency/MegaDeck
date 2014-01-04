//
//  MDStutterPlayer.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/30/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDStutterPlayer.h"
#import "MDCircularSoundModel.h"

@implementation MDStutterPlayer

static OSStatus audioOutputCallback(void *inRefCon, 
                                    AudioUnitRenderActionFlags *ioActionFlags, 
                                    const AudioTimeStamp *inTimeStamp, 
                                    UInt32 inBusNumber, 
                                    UInt32 inNumberFrames, 
                                    AudioBufferList *ioData) {
    StutterStruct *sound = (StutterStruct *)inRefCon;
	
    AudioBuffer outbuffer = ioData->mBuffers[0];
	UInt32 *renderBuffer = (UInt32 *)outbuffer.mData;
	int bytesToCopy = outbuffer.mDataByteSize;
	
	// get pointer to buffer and available bytes
	int32_t availableBytes;
	UInt32 *circle = TPCircularBufferTail(sound->buffer, &availableBytes);
	
	if( *sound->length > 0 )
	{
		UInt32 remainingFrames = *sound->length - sound->position;
		UInt32 availbleFrames = availableBytes / 4;
		UInt32 framesToRead = MIN(inNumberFrames, MIN(remainingFrames, availbleFrames));
		int32_t bytes = framesToRead * 4;
		memcpy(renderBuffer, circle + sound->position, bytes);
		sound->position = (sound->position + framesToRead) % *sound->length;
	}
	else
	{		
		int32_t sampleCount = MIN(bytesToCopy, availableBytes);
		memcpy(renderBuffer, circle, sampleCount);
		TPCircularBufferConsume(sound->buffer, sampleCount);
	}
	
	
    return noErr;
}

- (id)init 
{
    self = [super init];
    if (self) 
	{
		stutter = (StutterStruct*)calloc(1, sizeof(StutterStruct));
		
		renderCallback.inputProc = audioOutputCallback;
		renderCallback.inputProcRefCon = stutter;
		
		// register for sound file loaded notifications
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self 
		 selector:@selector(soundDidLoad) 
		 name:FILE_LOADING object:nil];
    }
    return self;
}

- (void) updateTime:(NSTimer*)theTimer
{
	if( first ) 
	{
		*stutter->length = 44100;
		first = NO;
	}
	else
	{
		*stutter->length /= 2;
	}
	
	if( *stutter->length < 700 ) 
	{
		*stutter->length = 0;
		first = YES;
	}
	
	NSLog(@"tic %ld", *stutter->length);
}

- (void) refreshModel
{
	NSLog(@"Player :: refreshModel");
	
	stutter->buffer		= [(MDCircularSoundModel*)soundModel bufferPtr];
	stutter->start		= [soundModel startPtr];
	stutter->length		= [soundModel lengthPtr];
	stutter->position	= 0;
	stutter->isReady	= [soundModel isReadyPtr];
	
	first = YES;
	ticToc = [[NSTimer 
					   scheduledTimerWithTimeInterval:3.0 
					   target:self 
					   selector:@selector(updateTime:) 
					   userInfo:nil 
					   repeats:YES] 
					  retain];
}

@end
