//
//  GrainSynthViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MDSynthViewController.h"
#import "GrainWaveView.h"
#import "GrainSynthController.h"
#import "GrainInfoView.h"
#import "TSACoreGraph.h"
#import "GrainKeyView.h"
#import "MDControlGroup.h"
#import "NSObject+Persistant.h"

@interface GrainSynthViewController : MDSynthViewController <MDWaveViewDelegate, MDKeyProtocol>
{
	GrainWaveView			*waveView;
	IBOutlet GrainInfoView	*infoView;
	GrainKeyView			*keyView;
	MDControlGroup			*group;
	
	GrainSynthController	*synth;
	TSACoreGraph			*graph;
	
	CADisplayLink			*displayLink;
	
	BOOL hasSecondTouch;
	float iniPeriod;
	float iniDepth;
	
	BOOL useXPitch; // curtis heavy style pitch control instead of filter
}

@property (nonatomic) BOOL portraitOrientation;

@end
