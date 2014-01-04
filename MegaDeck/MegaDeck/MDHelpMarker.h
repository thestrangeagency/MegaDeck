//
//  MDHelpMarker.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 7/23/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class MDHelpView;

@interface MDHelpMarker : UIView
{
	MDHelpView *helpView;
	CADisplayLink *displayLink;
	float diameter;
}

@property (retain) MDHelpView *helpView;

@end
