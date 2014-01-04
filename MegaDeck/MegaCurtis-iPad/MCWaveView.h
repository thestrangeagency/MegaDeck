
//  renders audio waveform
//	rather than inherit, custom rewrite of MDWaveView

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MDSoundModel.h"

@interface MCWaveView : UIView 
{
	MDSoundModel	*soundModel;	// source of wave data
	SInt16			*audioData;		// subsampled into here
	
	BOOL			shouldZoomToSelection;
	BOOL			shouldUseWaveView;

	CADisplayLink	*displayLink;
	
	int				samples;		// subsample audio to this many
}

/**
 * loading soundModel subsamples it into audioData buffer which is displayed
 */
@property (retain, nonatomic) MDSoundModel *soundModel;

/**
 * automatically display selected portion based on start and length in sound model
 */
@property BOOL		shouldZoomToSelection;


// resample model
- (void) update;

// resample and redraw
- (void) refresh;

// animate display
- (void) animate;
- (void) pause:(BOOL)shouldPause;

@end
