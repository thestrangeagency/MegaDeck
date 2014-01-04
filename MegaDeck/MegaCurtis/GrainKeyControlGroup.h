//
//  GrainKeyControlGroup.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/24/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControlGroup.h"
#import "GrainSynthViewController.h"

@interface GrainKeyControlGroup : MDControlGroup
{
	MDInverseButton *waveKeysButton;
	GrainSynthViewController *controller;
}

@property (retain, nonatomic) GrainSynthViewController *controller;

@end
