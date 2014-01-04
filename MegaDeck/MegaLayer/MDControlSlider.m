//
//  MDControlSlider.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#define WIDTH			128
#define BORDER			8
#define SLIDER_RECT		8, 24, WIDTH, 8
#define WHITE_COLOR	 colorWithRed:.31f green:.78f blue:.86f alpha:1.f

#import "MDControlSlider.h"

@implementation MDControlSlider

@synthesize value, offValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        value = 0;
		offValue = 0;
		[label setTextColor:[UIColor WHITE_COLOR]];
    }
    return self;
}

- (void)dealloc 
{
    [onText release];
	[offText release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect valueRect = CGRectMake(SLIDER_RECT);
	CGContextClearRect(context, valueRect);
	valueRect.size.width = width * WIDTH;
	//CGContextSetGrayFillColor(context, 1.f, 1.f);
	CGContextSetRGBFillColor(context, .31f, .78f, .86f, 1.f);
	CGContextFillRect(context, valueRect);
}

- (void) setDelegate:(id<MDControlDelegate>)delegate
{
	_delegate = delegate;
	[self refresh];
}

- (void) refresh
{
	value = [_delegate getValue:self];
	width = [self toControl:value];

	[self setNeedsDisplay];
}

// ----------------------------------------------------------------------- label
#pragma mark - label

- (void) setLabelText:(NSString*)labelText
{
	[super setLabelText:labelText];
	onText = [[labelText copy] retain];
}

- (void) setLabelOffText:(NSString*)labelText
{
	offText = [[labelText copy] retain];
}

- (void) clearLabelOffText
{
	[offText release];
	offText = nil;
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	if( location.x < BORDER )
	{
		width = 0;
	}
	else if( location.x > BORDER + WIDTH )
	{
		width = 1;
	}
	else
	{	
		width = (location.x - BORDER) / WIDTH;
	} 

	value = [self fromControl:width];
	
	// optinally adjust label text
	if( offText )
		[super setLabelText: (value == offValue) ? offText : onText];
	
	[self.delegate valueChanged:self];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self setBackgroundColor:[UIColor whiteColor]];
	[label setBackgroundColor:[self backgroundColor]];
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setBackgroundColor:[UIColor blackColor]];
	[label setBackgroundColor:[self backgroundColor]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
