//
//  WaveButtonView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "WaveButtonView.h"
#import "MathUtil.h"
#import "MegaSpaceAppDelegate.h"

@implementation WaveButtonView

- (id)initWithFrame:(CGRect)frame wave:(wave)_shape table:(wave)_table
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        shape = _shape;
		table = _table;
		synth = (SpaceSynthController *)[[MegaSpaceAppDelegate sharedAppDelegate] synth];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{	
	int rows = self.bounds.size.height * 2;
	float step = .5;
	float x,y = 0;
	float width = self.bounds.size.width;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	CGContextSetRGBFillColor( context, 1, 1, 1, 1);
	CGContextSetLineWidth( context, step );
	CGContextSetShouldAntialias( context, NO );
	CGRect rowRect = CGRectMake(0, 0, 0, step);
	
    for(int i=0; i<rows; i++)
	{
		y += step;
		float fraction = (float)i/rows;
		
		if( shape == SIN )
			x = width * .5 + width * .5 * sinf(TWO_PI * fraction);
		
		else if( shape == SAW )
			x = width * fraction;
		
		else if( shape == SQUARE )
			x = width * (i < rows/2 ? -1 : 1); 
		
		else if( shape == FLAT )
			x = width * .5; 

		else if( shape == BIT4 )
			x = 8.f * floorf(y/8.f);
		
		else if( shape == BIT8 )
			x = 4.f * floorf(y/4.f);
		
		else if( shape == BIT16 )
			x = y; 
		
		rowRect.size.width = x;
		rowRect.origin.y = y;

		CGContextFillRect(context, rowRect);
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[synth setTarget:shape forTable:table];
}

@end
