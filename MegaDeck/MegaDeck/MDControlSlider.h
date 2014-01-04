//
//  MDControlSlider.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControl.h"

@interface MDControlSlider : MDControl
{
	float		value;	// actual value
	float		width;	// displayed value
	
	NSString	*onText;	// normal text
	NSString	*offText;	// optional alt text at one slider extreme
	float		offValue;
}

@property float value;
@property float offValue;

- (void) setLabelOffText:(NSString*)labelText;
- (void) clearLabelOffText;

@end
