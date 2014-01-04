//
//  SliceSubLoopView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/21/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceSubLoopView.h"

@interface SliceSubLoopView ()

- (void) updateFraction;

@end

@implementation SliceSubLoopView

@synthesize loop;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		fraction = 1;
		index = 0;
		
        fractionButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		[fractionButton addTarget:self action:@selector(onFractionTouch) forControlEvents:UIControlEventTouchUpInside];
		[self updateFraction];
		[self addSubview:fractionButton];
    }
    return self;
}

- (void)dealloc 
{
    [fractionButton release];
	[loop release];
    [super dealloc];
}

- (void) onFractionTouch
{
	fraction *= 2;
	if (fraction == 8) fraction = 1;
	if (index >= fraction) index = 0;
	width = 160.f / fraction;
	
	[self updateFraction];
}

- (void) updateFraction
{
	[fractionButton setTitle:[NSString stringWithFormat:@"/%i",fraction] forState:UIControlStateNormal];
	[loop setFraction:fraction withIndex:index];
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();    
	CGContextClearRect(c, rect);
	
	if( fraction == 1 ) return;
	
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
    CGContextBeginPath(c);
	
	CGContextAddRect(c, CGRectMake(fractionButton.frame.size.width + width*index, 0, width, 40));
	
    CGContextClosePath(c); 
    CGContextFillPath(c);
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
	float x = [touch locationInView:self].x - fractionButton.frame.size.width;
	
	index = floorf(x / width);
	
	[self updateFraction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{       
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self handleTouches:touches];
}

@end
