//
//  MDEnvelopeControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/15/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"
#import "TSASynthProtocol.h"

@interface MDEnvelopeControlPanel : MDControlPanel
{
	MDControlSlider *attackSlider;
	MDControlSlider *decaySlider;	
	MDControlSlider *sustainSlider;
	MDControlSlider *releaseSlider;
	MDInverseButton *holdButton;
	
	id<TSASynthProtocol> synth;
}

@end