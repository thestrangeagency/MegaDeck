//
//  GrainProControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/27/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//  shows pro version features, with link to buy

#import "MDControlPanel.h"
#import "MDTextBox.h"

@interface GrainProControlPanel : MDControlPanel
{
	MDInverseButton *buyButton;
	MDTextBox		*textBox;
}

@end
