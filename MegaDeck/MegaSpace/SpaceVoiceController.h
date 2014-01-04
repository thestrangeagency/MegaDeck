
#import <GLKit/GLKit.h>
#import "TSASynthVoiceController.h"

typedef struct
{
	SInt16 *waveTableA;
	SInt16 *waveTableB;
	float xFade;
	float position;
	
	float		*render;	// store the rendered sound, use for drawing
	int			offset;
	int			stride;
	int			count;
	int			index;
	BOOL		renderColor; // from user prefs
	
	SInt16		sample;		// instantaneous sample
	
	Voice	*superVoice;
	
} SpaceVoice;

@interface SpaceVoiceController : TSASynthVoiceController
{
	SpaceVoice *spaceVoice;
}

@property SpaceVoice *spaceVoice;
@property (nonatomic) SInt16 *waveTableA;
@property (nonatomic) SInt16 *waveTableB;
@property (nonatomic) float xFade;
@property (nonatomic, readonly) SInt16 sample;

/**
 * set up a buffer to render into
 */
- (void) setRenderBuffer:(float*)buffer offset:(int)offset stride:(int)stride count:(int)max;

/**
 * get the current rendering index
 */
- (int) renderIndex;

@end
