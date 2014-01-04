//
//  GrainVectorView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/9/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	View of grain waveforms
//	Could almost inherit from MDWaveView but uses a vector with stride as rendering source
//	Seems easier to just reimplement


#import <UIKit/UIKit.h>
#import "GrainVoiceController.h"

@interface GrainVectorView : UIView
{
	GrainVoice		*grainVoice;	// source of wave data
	float			*audioDataL;	// subsampled into here
	float			*audioDataR;
	int				drawPosition;
	
	unsigned char *data;
	CGContextRef bitmapContext;
}

@property GrainVoice *grainVoice;

// resample and redraw
- (void) refresh;

@end
