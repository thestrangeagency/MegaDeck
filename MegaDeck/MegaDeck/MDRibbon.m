//
//  MDRibbon.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/24/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDRibbon.h"

@implementation MDRibbon

@synthesize value, isLandscape;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        value = 0;
		isLandscape = YES;
    }
    return self;
}

- (void) setDelegate:(id<MDControlDelegate>)delegate
{
	[super setDelegate:delegate];
	value = [delegate getValue:self];
	[self setNeedsDisplay];
}

// ----------------------------------------------------------------------- touches
#pragma mark touches

- (void)handleTouches:(NSSet *)touches
{	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	value = isLandscape ? location.x / self.bounds.size.width : location.y / self.bounds.size.height;
	value = MIN(1.f, MAX(0.f, value));
	
	[self.delegate valueChanged:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
