//
//  GrainPosControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/26/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"
#import "GrainSynthController.h"

@interface GrainPosControlPanel : MDControlPanel
{
	MDControlSlider *startJitter;
	MDControlSlider *startModRate;
	MDControlSlider *startModDepth;
	MDControlSlider *startSlewSlider;
	
	GrainSynthController *synth;
}
@end
