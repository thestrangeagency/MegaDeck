
// essentially a wavetable synth

#import "TSASynthController.h"
#import "SpaceVoiceController.h"

#define SPACE_FRAMES			6000
#define SPACE_TABLE_CHANGED		@"SPACE_TABLE_CHANGED"

typedef enum 
{
	SIN,
	SAW,
	SQUARE,
	FLAT,
	MEM,
	
	A,
	B,
	
	BIT4,
	BIT8,
	BIT16,
} wave;

@interface SpaceSynthController : TSASynthController
{
	SInt16 *waveTableA;
	SInt16 *waveTableB;
	
	SInt16 **waveData;	
}

@property (readonly) SInt16 *waveTableA;
@property (readonly) SInt16 *waveTableB;

- (void) initTables;
- (SInt16*) tableForWave:(wave)table;

- (void) setXFade:(float)xFade;

- (SInt16) sampleVoice:(int)voice;
- (void) setRenderBuffer:(float*)buffer offset:(int)offset stride:(int)stride count:(int)count forVoice:(int)voice;
- (int) renderIndexForVoice:(int)voice;

- (void) setTarget:(wave)target forTable:(wave)table;

@end
