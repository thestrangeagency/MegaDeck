//
//  SpaceSculptView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SpaceSculptView.h"
#import "MathUtil.h"
#import <Accelerate/Accelerate.h>
#import "SpaceSynthController.h"
#import "MegaSpaceAppDelegate.h"

float gauss(float x, float sigma)
{
	return (1.f/(sqrtf(2.f*M_PI)*sigma))*expf(-(x*x)/(2.0f*sigma*sigma));
}

#define RANGE					512	// max touch range +/- in audio samples

@interface SpaceSculptView ()

- (void) update;
- (void) refresh;
- (void) smoothSet:(float)x atPosition:(float)fraction;

@end

@implementation SpaceSculptView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        samples = (self.frame.size.height-48) * 2;
		sculptData = calloc(samples, sizeof(float));
		
		gaussKernel = NULL;
		[self setKernelSize:64];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(refresh) 
													 name:SPACE_TABLE_CHANGED 
												   object:nil];
		
		synth = (SpaceSynthController *)[[MegaSpaceAppDelegate sharedAppDelegate] synth];
    }
    return self;
}

- (void)dealloc 
{
    free(sculptData);
	[selectorView release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) setKernelSize:(int)s
{
	kernelSize = s;
	gaussKernel = malloc(kernelSize * sizeof(float));
	for( int i=0; i<kernelSize; i++ )
	{
		gaussKernel[i] = gauss((i-kernelSize/2)/(float)(kernelSize/2), .4);
	}
	temp = malloc((kernelSize+RANGE) * sizeof(float));
}

- (void) setTarget:(wave)table
{
	[selectorView removeFromSuperview];
	[selectorView release];
	selectorView = [[WaveSelectorView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-48, self.frame.size.width, 48) table:table];
	[self addSubview:selectorView];
	
	[self setSource:[synth tableForWave:table] samples:SPACE_FRAMES];
}

- (void) setSource:(SInt16*)data samples:(int)count
{
	sourceData = data;
	sourceSamples = count;
	[self refresh];
}

- (void) refresh
{
	[self update];
	[self setNeedsDisplay];
}

- (void) smoothSet:(float)value atPosition:(float)fraction
{
	NSLog(@"smooth: %f, %hd", value, normFloatToSInt16(value));
	
	int index = sourceSamples * fraction;
	value = normFloatToSInt16(value);
	
	int range = RANGE;
	for(int i=1-range; i<range; i++)
	{
		int nearIndex = index + i;
		
		// OPTION wrap the smoothing
		nearIndex %= sourceSamples;
		//if( nearIndex < 0 || nearIndex >= sourceSamples ) continue;
		
		float oldval = sourceData[nearIndex];
		float newval = value;
		float avgval = ( oldval*(float)abs(i) + newval*(float)((range)-abs(i)) ) / (float)(range);
		
		// NSLog(@"avg: %i, old %f, new %f, avg %f", i, oldval, newval, avgval);
		
		sourceData[nearIndex] = (SInt16)avgval;
	}
	
	[self update];
	
	/* TODO revisit convolution
	index = CLAMP(index, RANGE, samples-RANGE);
	//vDSP_conv(&sculptData[index-RANGE/2], 1, &gaussKernel[kernelSize-1], -1, &sculptData[index-RANGE/2], 1, RANGE, kernelSize);
	//or
	
	float *x = &sculptData[index-RANGE/2];
	for (int i = 0; i < RANGE; i++ )
	{
		temp[i] = 0;                       // set to zero before sum
		float gaussSum = 0;
		for (int j = 0; j < kernelSize; j++ )
		{
			temp[i] += x[i - (j-kernelSize/2)] * gaussKernel[j];    // convolve: multiply and accumulate
			gaussSum += gaussKernel[j];
		}
		temp[i] /= gaussSum;
	}
	for (int i = 0; i <RANGE; i++ )
	{
		x[i] = temp[i];
	}
	 */
}

- (void) update
{
	float step = 0;
	float stepSize = sourceSamples / samples;
	int points = (int)samples;
	
	for(int i=0; i<points; i++)
	{			
		sculptData[i] = SInt16ToNromFloat( sourceData[ (int)round(step) ] );
		step += stepSize;
	}
}

- (void)drawRect:(CGRect)rect
{
    float scale = .5;
	float width = self.bounds.size.width;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	CGContextSetRGBStrokeColor( context, 1, 1, 1, 1 );
	CGContextSetRGBFillColor( context, 1, 1, 1, 1);
	CGContextSetLineWidth( context, scale );
	CGContextSetShouldAntialias( context, NO );
	
	//CGContextBeginPath(context);
	//CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	
	int points = samples;
	
	for( int i=0; i<points; i++)
	{
		float y = i*scale;
		//CGContextAddLineToPoint(context, width * sculptData[i], y);
		CGContextFillRect(context, CGRectMake(0, y, width * sculptData[i], scale));
	}
	
	//CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
	//CGContextClosePath(context);
	//CGContextFillPath(context);
	//CGContextStrokePath(context);
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	float height = self.bounds.size.height-48;
	float width = self.bounds.size.width;
	
	CGPoint location = [touch locationInView:self];
	location.x = CLAMP(location.x, 0, width);
	location.y = CLAMP(location.y, 0, height);
	
	[self smoothSet:location.x / width 
		 atPosition:location.y / height];	
	
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

@end
