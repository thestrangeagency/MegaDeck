//
//  MDControlGroup.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/20/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControlGroup.h"

@implementation MDControlGroup

- (id)initWithPanel:(MDControlPanel*)_panel
{
    self = [super init];
    if (self) 
	{
        panel = _panel;
    }
    return self;
}

- (void) valueChanged:(MDControl*)control
{
	// override	
}

- (float) getValue:(MDControl*)control
{
	// override
	return 0;
}

@end
