//
//  MDMixControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TSASynthProtocol.h"

@interface MDMixControlPanel : MDControlPanel
{
	MDControlSlider *volumeSlider;
	MDControlSlider *squashSlider;
	MDControlSlider *tremoloRateSlider;
	MDControlSlider *tremoloDepthSlider;
	
	id<TSASynthProtocol> synth;
	AudioUnit mMixer;
	AudioUnit mCompressor;
}

// for apps that no have tremolo
- (void) hideTremolo;

@end
