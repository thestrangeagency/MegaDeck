//
//  GrainKeyView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/25/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//  adds grain voice views

#import "MDKeyView.h"

@interface GrainKeyView : MDKeyView
{
	NSMutableArray			*voiceViews;
}

- (void) refresh;

// set all voiceview centers
- (void) setCenter:(CGPoint)center;

@end
