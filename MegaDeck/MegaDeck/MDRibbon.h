//
//  MDRibbon.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/24/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControl.h"
#import <QuartzCore/QuartzCore.h>

@interface MDRibbon : MDControl
{
	float value;	// actual value
	BOOL isLandscape;
}

@property float value;
@property BOOL isLandscape;

// protected
- (void)handleTouches:(NSSet *)touches;

@end
