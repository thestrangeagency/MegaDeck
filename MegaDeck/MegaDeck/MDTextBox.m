//
//  MDTextBox.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/27/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDTextBox.h"

@implementation MDTextBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		// default text box size
		[label setFrame:CGRectMake(8, 8, 144+48, 48 * 4)];
		[label setNumberOfLines:20];
    }
    return self;
}

@end
