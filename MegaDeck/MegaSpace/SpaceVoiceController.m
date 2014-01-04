
#import "SpaceVoiceController.h"
#import "SpaceSynthController.h"

void slew(float *from, float *to, float rate)
{
	*from = (1.0f-rate)*(*from) + rate*(*to);
}

// --------------------------------------------------------------------------------
#pragma mark -

static OSStatus renderGrains(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	SpaceVoice *voice = (SpaceVoice*)inRefCon;
	Voice *superVoice = voice->superVoice;
	
	AudioBuffer buffer = ioData->mBuffers[0];
	UInt32 *frameBuffer = (UInt32 *)buffer.mData;
	SInt16* left;
	SInt16* right;
	
	// portamento
	if( superVoice->portamento.settings->slewTime > 0 )
		superVoice->frequency += (superVoice->portamento.destination - superVoice->frequency) / superVoice->portamento.settings->slewTime;
	else
		superVoice->frequency = superVoice->portamento.destination;
	
	if( voice->waveTableA == NULL )
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
		float vibrato = powf(2, superVoice->vibrato.level);
		float packetStep = SPACE_FRAMES * (voice->superVoice->frequency * vibrato) / 44100.f;
		
		for( int i=0; i<inNumberFrames; i++ )
		{
			left = (SInt16*)&frameBuffer[i];
			right = left+1;
			
			float average = voice->waveTableB[(int)voice->position] * voice->xFade + voice->waveTableA[(int)voice->position] * (1.f - voice->xFade);
			
			*left = average * superVoice->gain * superVoice->amplitude.smoothLevel * (1 - ABS(superVoice->tremolo.level));
			*right = *left;
			
			voice->sample = *left;
			if( voice->render )
			{
				voice->render[voice->index + voice->offset] = 64.f * (*left / 32768.f);
				// OPTION color
				if( voice->renderColor )
					voice->render[voice->index + voice->offset + 4] = (1.f+(*left / 32768.f))/2.f;
				voice->index += voice->stride;
				if( voice->index + voice->offset >= voice->count ) voice->index = 0;
			}
			
			voice->position += packetStep;
			if( voice->position > SPACE_FRAMES ) voice->position = 0;
									
			// mod
			stepEnvelope(&superVoice->amplitude);
			stepLFO(&superVoice->tremolo);
			stepLFO(&superVoice->vibrato);
		}
	}
	
    return noErr;
}

@implementation SpaceVoiceController

@synthesize spaceVoice;

-(void) initVoice
{	
	[super initVoice];
	
	spaceVoice = (SpaceVoice*)calloc(1, sizeof(SpaceVoice));	
	spaceVoice->superVoice = voice;
	spaceVoice->waveTableA = NULL;
	spaceVoice->waveTableB = NULL;
	spaceVoice->xFade = 0;
	spaceVoice->render = NULL;
	
	spaceVoice->renderColor = [[NSUserDefaults standardUserDefaults] boolForKey:@"color_wave_view"];
}

-(void) initCallback
{
	renderCallback.inputProc = renderGrains;
	renderCallback.inputProcRefCon = spaceVoice;
}

- (void) notePressed:(int)noteNumber withVelocity:(int)velocity
{
	[super notePressed:noteNumber withVelocity:velocity];
		
	voice->tremolo.step = 0;
	voice->vibrato.step = 0;
}

// ---------------------------------------------------------------------------------------------------- tables
#pragma mark - tables

- (SInt16*) waveTableA
{
	return spaceVoice->waveTableA;
}

- (SInt16*) waveTableB
{
	return spaceVoice->waveTableB;
}

- (void) setWaveTableA:(SInt16 *)waveTable
{
	spaceVoice->waveTableA = waveTable;
}

- (void) setWaveTableB:(SInt16 *)waveTable
{
	spaceVoice->waveTableB = waveTable;
}

- (float) xFade
{
	return spaceVoice->xFade;
}

- (void) setXFade:(float)xFade
{
	spaceVoice->xFade = xFade;
}

// ---------------------------------------------------------------------------------------------------- rendering
#pragma mark - rendering

- (SInt16) sample
{
	return spaceVoice->sample;
}

- (void) setRenderBuffer:(float*)buffer offset:(int)offset stride:(int)stride count:(int)max
{
	spaceVoice->render = buffer;
	spaceVoice->offset = offset;
	spaceVoice->stride = stride;
	spaceVoice->count  = max * stride;
	spaceVoice->index  = 0;
}

- (int) renderIndex
{
	return spaceVoice->index;
}

@end
