//
//  MDHelpMarker.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 7/23/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDHelpMarker.h"
#import "MDHelpView.h"

@implementation MDHelpMarker

@synthesize helpView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        [self setOpaque:NO];
		[self setBackgroundColor:[UIColor clearColor]];
		
		diameter = frame.size.width;
		
		// NOTE too much animation for iPhone
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
		[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		[displayLink setFrameInterval:5];
    }
    return self;
}

- (void)dealloc 
{
    [helpView release];
	[displayLink invalidate];
    [super dealloc];
}

// ----------------------------------------------------------------------- animation
#pragma mark - animation

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	float offset = (rect.size.width - diameter) / 2;
	CGRect fillRect = CGRectMake(offset, offset, diameter, diameter);
    CGContextAddEllipseInRect(ctx, fillRect);
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextFillPath(ctx);
}

- (void) updateDisplay:(CADisplayLink *)sender
{
	diameter = 30.f + 10.f * sinf((float)[sender timestamp]+M_PI_4*self.tag);
	[self setNeedsDisplay];
}


// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{	
	[helpView touchMarker:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

@end
