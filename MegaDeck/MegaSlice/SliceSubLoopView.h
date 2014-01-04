//
//  SliceSubLoopView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/21/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDInverseButton.h"
#import "SliceLoopModel.h"

@interface SliceSubLoopView : UIView
{
	MDInverseButton *fractionButton;
	
	int		fraction;	// of the loop
	int		index;		// of sub loop
	float	width;		// of sub loop trigger
	
	SliceLoopModel *loop;
}

@property (retain) SliceLoopModel *loop;

@end
