//
//  MDLowPassControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/14/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"
#import "TSACoreFeedback.h"

@interface MDFxControlPanel : MDControlPanel
{
	MDControlSlider *cutoffSlider;
	MDControlSlider *resonanceSlider;

	MDControlSlider *delayLevelSlider;	
	MDControlSlider *delayLengthSlider;
	
	TSACoreGraph	*graph;
	TSACoreFeedback *echo;
}

@end