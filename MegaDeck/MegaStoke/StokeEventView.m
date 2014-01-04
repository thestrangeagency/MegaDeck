//
//  StokeEventView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeEventView.h"

@implementation StokeEventView

@synthesize event;

- (id)init 
{
    self = [super init];
    if (self) 
	{
        [super initWithFrame:CGRectMake(0, 0, 40, 40)];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setOpaque:NO];
    }
    return self;
}

- (void)dealloc 
{
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillPath(ctx);
	
	CGContextSetLineWidth(ctx, 1);

	// draw arcs for event params
	
	if( event )
	{
		float params[4] = 
		{ 
			event->velocity, 
			event->decay, 
			event->noteNumber, 
			event->grainStart 
		};
		
		for (int i=0; i<4; i++) 
		{
			CGContextBeginPath(ctx);
			CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.f - params[i] alpha:1].CGColor);
			CGContextAddArc(ctx, 20, 20, 18 - 2 * i, -M_PI_2, -M_PI_2 + M_PI * 2.f * params[i], 0);
			CGContextStrokePath(ctx);
		}
	}
	
	// draw selection
	
	if( isSelected )
	{
		CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
		CGContextAddEllipseInRect(ctx, CGRectMake(16, 16, 8, 8));
		CGContextStrokePath(ctx);
	}
}

- (void) update
{
	if( event->isTriggered )
	{
		[UIView animateWithDuration:0.1 
							  delay:0.0 
							options:UIViewAnimationCurveEaseOut 
						 animations:^ {
							 [self setAlpha:0];
						 } 
						 completion:^(BOOL finished) {
							 [self setAlpha:1];
						 }];
		event->isTriggered = NO;
	}
	if( event->isSkipped )
	{
		event->isSkipped = NO;
	}
}

- (void) setIsSelected:(BOOL)shouldSelect
{
	[super setIsSelected:shouldSelect];
	[self setNeedsDisplay];
}

- (void) refresh
{
	[self setNeedsDisplay];
}

@end
