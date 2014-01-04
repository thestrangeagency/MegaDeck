//
//  GrainControlGroup.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/20/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControlGroup.h"
#import "MDControlSlider.h"
#import "GrainSynthController.h"

@interface GrainControlGroup : MDControlGroup
{
	MDControlSlider *sizeJitter;
	MDControlSlider *overlap;
	MDControlSlider *overlapModRate;
	MDControlSlider *overlapModDepth;
	
	GrainSynthController *synth;
}

@end
