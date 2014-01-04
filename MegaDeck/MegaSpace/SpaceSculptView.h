//
//  SpaceSculptView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WaveSelectorView.h"

@interface SpaceSculptView : UIView
{
	SInt16	*sourceData;	// source of wave data
	int sourceSamples;
	float *sculptData;		// subsampled into here
	float samples;
	
	float *gaussKernel;
	int kernelSize;
	float *temp;

	SpaceSynthController *synth;
	WaveSelectorView *selectorView;
}

- (void) setTarget:(wave)table;
- (void) setSource:(SInt16*)data samples:(int)count;
- (void) setKernelSize:(int)s;

@end
