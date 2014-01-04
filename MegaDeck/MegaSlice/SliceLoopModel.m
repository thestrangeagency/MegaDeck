//
//  SliceLoopModel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceLoopModel.h"
#import "SliceView.h"
#import "SliceLoopView.h"

static inline void scaleFrame(UInt32 *frame, float gain)
{
	SInt16* left = (SInt16*)frame;
	SInt16* right = left+1;

	*left  = *left  * gain;
	*right = *right * gain;
}

static inline float speedFromTransport(TransportModel* transport, UInt32 length, float bars)
{
	Float64 loopSamples = bars * 44100.f / ( transport->bpm / 240.f);
	return length / loopSamples;
}

static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	LoopStruct *loop = (LoopStruct*)inRefCon;
	if( loop->audioData == NULL ) return noErr;
		
	AudioBuffer buffer = ioData->mBuffers[0];
	UInt32 *frameBuffer = (UInt32 *)buffer.mData;
	
	// adjust length for realtime audio trim and subloop fraction
	loop->sliceLength = (*loop->lengthPtr / N_SLICES) / loop->fraction;
	
	// adjust speed
	loop->speed = speedFromTransport(loop->transportModel, *loop->lengthPtr, loop->bars) * loop->speedMultiplier;
	
	for( int i=0; i<inNumberFrames; i++ )
	{	
		if( !loop->transportModel->isPlaying || loop->isEmpty )
		{
			// stopped so clear output
			frameBuffer[i] = 0;
		}
		else 
		{
			// fill current frame
			if( loop->isMuted )
			{
				frameBuffer[i] = 0;
			}
			else
			{
				frameBuffer[i] = loop->audioData[ loop->slices[loop->currentSlice].startTime + loop->offset ];
				scaleFrame(&frameBuffer[i], loop->gain);
			}

			// advance position
			loop->floatOffset += loop->speed;
			loop->offset = (int)loop->floatOffset;
			
			// negative tempo? just loop on this slice for some glitch
			if( loop->offset < 0 )
			{
				loop->floatOffset = loop->offset = loop->sliceLength - 1;
			}
			
			// check bounds
			if( loop->offset >= loop->sliceLength )
			{
				// queue up next slice
				loop->offset = 0;
				loop->floatOffset = 0;
				
				// find next active slice
				int counter = 0;
				while (true)
				{
					loop->currentPosition = (loop->currentPosition + 1) % 16;
					if (loop->slices[loop->sliceIndexes[loop->currentPosition]].isActive)
					{
						// found next slice
						// set newly-triggered flag
						loop->slices[loop->sliceIndexes[loop->currentPosition]].isNew = YES;
						break;
					}
					
					// if we go through whole slice array without active slice, loop is empty
					counter++;
					if (counter >= 16)
					{
						loop->isEmpty = YES;
						break;
					}
				}
				
				loop->currentSlice = loop->sliceIndexes[loop->currentPosition];
				
				// adjust slice start time for realtime audio trim
				loop->slices[loop->currentSlice].startTime = *loop->startPtr + loop->currentSlice * loop->sliceLength;
				
				// add in subloop offset
				if( loop->index > 0 )
				{
					loop->slices[loop->currentSlice].startTime += loop->index * loop->sliceLength * N_SLICES;
				}
			}
		}
	}
	
    return noErr;
}

// --------------------------------------------------------------------------------
#pragma mark -

@implementation SliceLoopModel

@synthesize renderCallback, soundModel, sliceViews, loop;

- (id)init 
{
    self = [super init];
    if (self) 
	{
        for (int i = 0; i < N_SLICES; i++)
        {
            loop.sliceIndexes[i] = i;
        }
        
		loop.currentPosition = 0;
		loop.audioData = NULL;
        loop.gain = 1;
		loop.transportModel = [[MDTransportModel sharedMDTransportModel] model];
		loop.speedMultiplier = 1;
		loop.isMuted = NO;
		
		renderCallback.inputProc = renderInput;
		renderCallback.inputProcRefCon = &loop;
		
        soundModel = [[MDSoundModel alloc] init];
		
		// effectively disable through button
		[soundModel setThroughOk:NO];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(soundDidLoad:) 
													 name:FILE_LOADED 
												   object:nil];
    }
    return self;
}
		 
- (void) setKeyAndReload:(NSString*)key
{
	[soundModel setLastFileKey:key];
	[soundModel readLastAudioFile];
}

-(void) soundDidLoad:(NSNotification*)note
{
	NSLog(@"SliceLoopModel noticed a new file");
	
	if( [note object] != soundModel )
	{
		// wrong loop, ignore
		NSLog(@"-  ignoring the new file");
		return;
	}
	else
	{
		NSLog(@"-  setting loop to new file");
	}

	loop.sliceLength = [soundModel length] / N_SLICES;
	loop.offset = 0;
	loop.currentSlice = 0;
	loop.floatOffset = 0;
	loop.isEmpty = NO;
	loop.fraction = 1;
	loop.index = 0;
	loop.speedMultiplier = 1;
	
	loop.bars = [[NSUserDefaults standardUserDefaults] floatForKey:@"bars_per_loop"];
	
	for (int i=0; i<N_SLICES; i++) 
	{
		loop.slices[i].startTime = [soundModel start] + i * loop.sliceLength;
		loop.slices[i].isActive = YES;
		loop.slices[i].isNew = NO;
	}

	// TODO ensure this executes last or things could get racy
	loop.audioData = [soundModel audioBuffer]->mData;

	// get pointers to sound properties
	loop.startPtr = [soundModel startPtr];
	loop.lengthPtr = [soundModel lengthPtr];
	
	NSLog(@"each new slice has %i frames", loop.sliceLength);
}

- (NSString*) lastPath
{
	return [soundModel lastPath];
}

- (void)setSliceViews:(NSMutableArray *)_sliceViews
{
    [_sliceViews retain];
    [sliceViews release];
    sliceViews = _sliceViews;
    
    for (int i = 0; i < sliceViews.count; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        loop.sliceIndexes[i] = slice.sliceID;
        loop.slices[slice.sliceID].sliceView = slice;
        
        // if any slice isn't muted, loop isn't empty
        if (!slice.isMuted)
            loop.isEmpty = NO;
    }
}

- (SliceStruct*) sliceAtIndex:(int)index
{
	return &loop.slices[index];
}

- (SliceStruct*) currentSlice
{
	return &loop.slices[loop.currentSlice];
}

- (SliceStruct*) currentPositionSlice
{
	return &loop.slices[loop.currentPosition];
}

- (void) setGain:(float)gain
{
	loop.gain = gain;
}

- (float) gain
{
	return loop.gain;
}

- (void) setFraction:(int)fraction withIndex:(int)index
{
	if( fraction < 1 || index < 0 ) return;
	if( index >= fraction ) return;
	
	loop.fraction = fraction;
	loop.index = index;
}

- (void) doubleSpeed
{
	loop.speedMultiplier *= 2;
}

- (void) halveSpeed
{
	loop.speedMultiplier *= .5;
}

- (void) restart
{
	loop.currentPosition = 0;
	loop.offset = 0;
	loop.floatOffset = 0;
	loop.currentSlice = loop.sliceIndexes[loop.currentPosition];
}

- (void) setIsMuted:(BOOL)isMuted
{
	NSLog(@"MUTE:%i",isMuted);
	loop.isMuted = isMuted;
}

- (BOOL) isMuted
{
	return loop.isMuted;
}

- (void)dealloc 
{
    [soundModel release];
    [super dealloc];
}

@end
