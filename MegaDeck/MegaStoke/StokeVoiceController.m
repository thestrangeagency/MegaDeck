//
//  StokeVoiceController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/4/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeVoiceController.h"
#import "StokeSynthController.h"
#import "GrainSynthController.h"

UInt32 getNextGrainSample(GrainVoice *voice);

static TimeStruct renderTime;

static OSStatus renderStokes(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	GrainVoice *voice = (GrainVoice*)inRefCon;
	Voice *superVoice = voice->superVoice;
	
	AudioBuffer buffer = ioData->mBuffers[0];
	UInt32 *frameBuffer = (UInt32 *)buffer.mData;
	SInt16* left;
	SInt16* right;
	
	// loop
	
	StokeLoop *loop = (StokeLoop *)voice->bonus;
	if( loop != NULL && !loop.isMuted )
	{
		renderTime.mSampleTime = inTimeStamp->mSampleTime;
		renderTime.inNumberFrames = inNumberFrames;
		[(StokeVoiceController*)superVoice->me performSelectorOnMainThread:@selector(trigger) withObject:nil waitUntilDone:NO];
	}
	
	if( voice->frames == 0 )
	{
		// play saw until grain file loaded
		
		for( int i=0; i<inNumberFrames; i++ )
		{
			left = (SInt16*)&frameBuffer[i];
			right = left+1;
			
			// lfo depth 1 = 1 semitone
			float vibrato = powf(2, superVoice->vibrato.level/12.0f);
			float period = 44100.0f / (superVoice->frequency * vibrato);
			float x = (float)superVoice->sample / period;
			float saw = (32768.0f * (x - 0.5f));
			
			*left  = (SInt16)(saw * superVoice->gain * superVoice->amplitude.smoothLevel * (1 - ABS(superVoice->tremolo.level)));
			*right = *left;
			
			superVoice->sample = (superVoice->sample + 1) % (long)period;
			
			stepEnvelope(&superVoice->amplitude);
			stepLFO(&superVoice->tremolo);
			stepLFO(&superVoice->vibrato);
		}
		
	}
	else
	{
		for( int i=0; i<inNumberFrames; i++ )
		{
			frameBuffer[i] = getNextGrainSample(voice);
			
			if( voice->grainStart > voice->frames ) voice->grainStart -= voice->frames;
			
			// mod
			stepEnvelope(&superVoice->amplitude);
			stepLFO(&superVoice->tremolo);
			stepLFO(&superVoice->vibrato);
			//stepLFO(&voice->startMod);
			//stepLFO(&voice->overlapMod);
		}
	}
	
    return noErr;
}

@implementation StokeVoiceController

- (id)initWithSynth:(TSASynthController*)_synth
{
    self = [super initWithSynth:_synth];
    if (self) 
	{
		transport = [[MDTransportModel sharedMDTransportModel] model];
    }
    return self;
}

- (void) initCallback
{
	renderCallback.inputProc = renderStokes;
	renderCallback.inputProcRefCon = grainVoice;
}

- (void) trigger
{
	if( !transport->isPlaying ) return;
	
	Float64 loopSamples = 44100.f / ( transport->bpm / 240.f);
	
	float start = renderTime.mSampleTime / loopSamples;
	start -= floorf(start);
	
	float end = (renderTime.mSampleTime + (Float64)renderTime.inNumberFrames) / loopSamples;
	end -= floorf(end);
		
	GrainSynthController *grainSynth = (GrainSynthController*)synth;
	
	StokeEvent *event = loop.head;
	if( event )
		do
		{
			if( (start < event->effective && event->effective < end) ||
			    // wrap edge case
			    (start > end && (start < event->effective || event->effective < end)) )
			{
				// roll dice
				float dice = loop.isProbable ? (float)(rand() % 100) / 100.f : 0.f; // if probability disabled, roll zero
				if( dice > event->probability )
				{
					event->isSkipped = YES;
				}
				else
				{
					event->isTriggered = YES;
				
					// fire
					//[self setStart:event->grainStart];
					//[self notePressed:event->noteNumber*60 withVelocity:event->velocity*128];
					
					[grainSynth setPosition:event->grainStart];
					[grainSynth notePressed:event->noteNumber*60 withVelocity:loop.level * event->velocity * 128];
					
					// simulate (no A) R envelope
					
					// no time for attack, so jump to max level
					voice->amplitude.level = 1.f;
					// using 'decay' param to control env release
					[synth setAmpRelease:event->decay];
					
					[self noteReleased];
				}
			}
		}
		while ((event = event->next));
}

- (void) setLoop:(StokeLoop*)_loop
{
	grainVoice->bonus = (void*)_loop;
	loop = _loop;
}

@end
