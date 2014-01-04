//
//  SliceLoopExtraView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/22/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	Some bonus loop params live here

#import <UIKit/UIKit.h>
#import "MDInverseButton.h"
#import "SliceLoopModel.h"
#import "SliceLoopView.h"

@interface SliceLoopExtraView : UIView
{
	MDInverseButton *resetButton;
	MDInverseButton *clearButton;
	MDInverseButton *doubleButton;
	MDInverseButton *halfButton;
	
	SliceLoopModel	*loop;
	SliceLoopView	*loopView;
}

@property (retain) SliceLoopModel	*loop;
@property (retain) SliceLoopView	*loopView;

@end
