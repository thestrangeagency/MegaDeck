//
//  GrainWaveView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	Interactive view of grain source

#import "MDWaveCursorView.h"

@interface GrainWaveView : MDWaveCursorView
{
	UITouch *firstTouch;
	BOOL	hasTouch;
	BOOL	hasSecondTouch;
	CGPoint secondLocationStart;
	CGPoint secondLocation;
	UILabel *secondCursor;
}

@property (nonatomic) float xFraction;
@property BOOL hasTouch;
@property BOOL hasSecondTouch;

// already normalized second touch location TODO make first touch access consistent
@property CGPoint secondLocation;
@property (readonly,nonatomic) CGPoint secondLocationDelta;

@end
