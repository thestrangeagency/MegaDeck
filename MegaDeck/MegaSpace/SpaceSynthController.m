
#import "SpaceSynthController.h"
#import "MathUtil.h"

@implementation SpaceSynthController

@synthesize waveTableA, waveTableB;

- (id) initWithVoiceCount:(int)nVoices
{
	self = [super initWithVoiceCount:nVoices];
    if (self) 
	{
		[self initTables];
		
		for( SpaceVoiceController *voice in voices )
		{
			voice.waveTableA = waveTableA;
			voice.waveTableB = waveTableB;
		}
		
		// [self setAmpHold:YES];
    }
    return self;
}

- (void) initVoices:(int)nVoices
{
	for( int i=0; i<nVoices; i++ )
	{
		SpaceVoiceController *voice = [[SpaceVoiceController alloc] initWithSynth:self];
		callbackStructs[i] = [voice renderCallback];
		voice.number = i;
		[voices addObject:voice];
		[voice release];
	}
}

- (void) dealloc
{
	free(waveData);
	[super dealloc];
}

- (void) initTables
{
	waveData = (SInt16**)calloc(7, sizeof(SInt16*));
	for( int i = 0; i<7; i++ )
		waveData[i] = (SInt16*)calloc(SPACE_FRAMES, sizeof(SInt16));
	
	waveTableA = waveData[A];
	waveTableB = waveData[B];
	
	for(int i=0; i<SPACE_FRAMES; i++)
	{
		waveData[SIN][i] = 32767.f * sinf(TWO_PI*(float)i/SPACE_FRAMES);
		
		waveData[SAW][i] = 32767.f * (-1 + 2 * (float)i/SPACE_FRAMES);
		
		waveData[SQUARE][i] = 32767.f * (i < SPACE_FRAMES/2 ? -1 : 1); 
		
		waveData[FLAT][i] = 0; 
		
		waveData[A][i] = waveData[SIN][i];
		waveData[B][i] = waveData[SAW][i];
	}
}

- (SInt16*) tableForWave:(wave)table
{
	return waveData[table];
}

- (void) setTarget:(wave)target forTable:(wave)table
{
	// TODO clean this up
	
	if( !(table == A || table == B) ) return;
	
	// copy from target table
	if( target <= FLAT )
		memcpy(waveData[table], waveData[target], SPACE_FRAMES * sizeof(SInt16));
	
	// reduce
	if( target == BIT4 )
		for(int i=0; i<SPACE_FRAMES; i++)
		{
			waveData[table][i] = 4096 * round(waveData[table][i] / 4096);
		}
	
	// reduce
	if( target == BIT8 )
		for(int i=0; i<SPACE_FRAMES; i++)
		{
			waveData[table][i] = 2048 * round(waveData[table][i] / 2048);
		}
	
	// smooth
	if( target == BIT16 )
	{
		float average = 0;
		// prime
		for(int i=SPACE_FRAMES-100; i<SPACE_FRAMES; i++)
		{
			average = average*.99 + waveData[table][i]*.01;
		}
		// running average
		for(int i=0; i<SPACE_FRAMES; i++)
		{
			average = average*.99 + waveData[table][i]*.01;
			waveData[table][i] = average;
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SPACE_TABLE_CHANGED object:[NSNumber numberWithInt:table]];
}

- (void) setXFade:(float)xFade
{
	for( SpaceVoiceController *voice in voices )
	{
		[voice setXFade:xFade];
	}
}

- (SInt16) sampleVoice:(int)voice
{
	return [[voices objectAtIndex:voice] sample];
}

- (void) setRenderBuffer:(float*)buffer offset:(int)offset stride:(int)stride count:(int)count forVoice:(int)voice
{
	[[voices objectAtIndex:voice] setRenderBuffer:buffer offset:offset stride:stride count:count];
}

- (int) renderIndexForVoice:(int)voice
{
	return [[voices objectAtIndex:voice] renderIndex];
}

@end
