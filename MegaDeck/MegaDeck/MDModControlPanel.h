//
//  MDModControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/20/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"
#import "TSASynthProtocol.h"

@interface MDModControlPanel : MDControlPanel
{
	MDControlSlider *vibratoRateSlider;
	MDControlSlider *vibratoDepthSlider;	
	MDControlSlider *portamentoSlider;
	
	id<TSASynthProtocol> synth;
}

@end