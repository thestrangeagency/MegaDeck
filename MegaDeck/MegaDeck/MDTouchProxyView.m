//
//  MDTouchProxyView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/15/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDTouchProxyView.h"

@implementation MDTouchProxyView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self setBackgroundColor:[UIColor clearColor]];
		[self setOpaque:NO];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.delegate touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.delegate touchesMoved:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.delegate touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.delegate touchesCancelled:touches withEvent:event];
}

@end
