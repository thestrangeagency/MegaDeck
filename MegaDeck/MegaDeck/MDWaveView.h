
//  renders audio waveform

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MDSoundModel.h"

#if TARGET_NAME == MegaCurtis_iPad
	#define PORTRAIT_DRAW_SAMPLES	1568.f // 2 * 784.0f
	#define LANDSCAPE_DRAW_SAMPLES	448.0f // not used
#else
	#define PORTRAIT_DRAW_SAMPLES	960.0f
	#define LANDSCAPE_DRAW_SAMPLES	448.0f
#endif

@interface MDWaveView : UIView 
{
	MDSoundModel	*soundModel;	// source of wave data
	SInt16			*audioData;		// subsampled into here
	
	BOOL			shouldZoomToSelection;
	CADisplayLink	*displayLink;
	BOOL			shouldUseWaveView;
	
	BOOL			isPortrait;
}

/**
 * loading soundModel subsamples it into audioData buffer which is displayed
 */
@property (retain, nonatomic) MDSoundModel *soundModel;

/**
 * automatically display selected portion based on start and length in sound model
 */
@property BOOL		shouldZoomToSelection;

/**
 * rotate the wave display, portrait == YES
 */
@property BOOL		portraitOrientation;

/**
 * override user defaults
 */
@property (nonatomic) BOOL shouldUseWaveView;

// resample model
- (void) update;

// resample and redraw
- (void) refresh;

// animate display
- (void) animate;
- (void) pause:(BOOL)shouldPause;

@end
