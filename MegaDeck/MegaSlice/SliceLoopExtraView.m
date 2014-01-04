//
//  SliceLoopExtraView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/22/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceLoopExtraView.h"

@interface SliceLoopExtraView ()

@end

@implementation SliceLoopExtraView
@synthesize loop,loopView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        resetButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		[resetButton addTarget:self action:@selector(onReset) forControlEvents:UIControlEventTouchUpInside];
		[resetButton setTitle:@"RST" forState:UIControlStateNormal];
		[self addSubview:resetButton];
		
		clearButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 48, 40, 40)];
		[clearButton addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
		[clearButton setTitle:@"CLR" forState:UIControlStateNormal];;
		[self addSubview:clearButton];
		
		doubleButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 96+8, 40, 40)];
		[doubleButton addTarget:self action:@selector(onDouble) forControlEvents:UIControlEventTouchUpInside];
		[doubleButton setTitle:@"x2" forState:UIControlStateNormal];
		[self addSubview:doubleButton];
		
		halfButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 96+8+48, 40, 40)];
		[halfButton addTarget:self action:@selector(onHalf) forControlEvents:UIControlEventTouchUpInside];
		[halfButton setTitle:@"/2" forState:UIControlStateNormal];
		[self addSubview:halfButton];
		
		[self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

// reset slice order
- (void) onReset
{
	[loopView resetSlices];
}

// unmute all slices
- (void) onClear
{
	[loopView unmuteAll];
}

// double speed
- (void) onDouble
{
	[loop doubleSpeed];
}

// half speed
- (void) onHalf
{
	[loop halveSpeed];
}

@end
