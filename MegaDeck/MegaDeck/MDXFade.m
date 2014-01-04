//
//  MDXFade.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/6/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDXFade.h"

@implementation MDXFade

- (void) update
{
	[aView setBackgroundColor:[UIColor colorWithWhite:1 alpha:1-value]]; 
	[bView setBackgroundColor:[UIColor colorWithWhite:1 alpha:value  ]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		float h = frame.size.height;
		aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, h, h)];
		bView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width-h, 0, h, h)];
		[aView setUserInteractionEnabled:NO];
		[bView setUserInteractionEnabled:NO];
		[self addSubview:aView];
		[self addSubview:bView];
		[self update];
    }
    return self;
}

- (void)dealloc 
{
    [aView release];
	[bView release];
    [super dealloc];
}

- (void) setLabelAText:(NSString*)labelText
{
	[super setLabelText:labelText];
}

- (void) setLabelBText:(NSString*)labelText
{
	float h = self.frame.size.height;
	[super addLabelWithFrame:CGRectMake(8+self.frame.size.width-h, 8, h, 11) text:labelText];
	[self bringSubviewToFront:bView];
}

- (void)handleTouches:(NSSet *)touches
{	
	[super handleTouches:touches];
	[self update];
}

@end
