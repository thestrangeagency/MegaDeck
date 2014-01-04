//
//  GrainVectorView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/9/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainVectorView.h"

#define DRAW_SAMPLES	400
#define DRAW_SAMPLES_f	400.f

@implementation GrainVectorView

@synthesize grainVoice;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		audioDataL = (float*)calloc(DRAW_SAMPLES, sizeof(float));
		audioDataR = (float*)calloc(DRAW_SAMPLES, sizeof(float));
		grainVoice = NULL;
		drawPosition = 0;
		
		CGFloat width = 40;
		CGFloat height = 40;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		size_t bitsPerComponent = 8;
		size_t bytesPerPixel    = 4;
		size_t bytesPerRow      = (width * bitsPerComponent * bytesPerPixel + 7) / 8;
		size_t dataSize         = bytesPerRow * height;
		
		data = malloc(dataSize);
		memset(data, 0xFF, dataSize);
		
		bitmapContext = CGBitmapContextCreate(data, width, height, 
											  bitsPerComponent, 
											  bytesPerRow, colorSpace, 
											  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		
		CGColorSpaceRelease(colorSpace);
		
		[self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

- (void)dealloc
{
	CGContextRelease(bitmapContext);
	free(data);
	free(audioDataL);
	free(audioDataR);
    [super dealloc];
}

- (void) update
{
	if( grainVoice == NULL ) return;
	
	// subsample rendered voice into local array
	
	float step = 0;
	float stepSize = (float)MAX_GRAIN_SIZE / DRAW_SAMPLES;

	for(int i=0; i<DRAW_SAMPLES; i++)
	{
		int index = 2 * (int)round(step);
		
		// z component contains audio amplitude, convert to dB
		audioDataL[i] = 20.f * log10f( ABS(grainVoice->renderLeft[  index ].z / 32768.0) );
		audioDataR[i] = 20.f * log10f( ABS(grainVoice->renderRight[ index ].z / 32768.0) );
		
		step += stepSize;
	}
}

- (void)drawRect:(CGRect)rect 
{
	if( grainVoice != NULL )
	{		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetShouldAntialias( context, NO );
		
		// samples to draw given grain size
	    int toDraw = DRAW_SAMPLES_f * (float)grainVoice->superVoice->period / MAX_GRAIN_SIZE_f;
			
		for( int i=0; i<DRAW_SAMPLES; i++)
		{
			int j = (i + drawPosition) % DRAW_SAMPLES;
			
			int x = j % 40;
			int y = j / 40;
			
			int grayL = toDraw > i ? (1.f + audioDataL[i]/40.f) * 0xFF : 0;
			int grayR = toDraw > i ? (1.f + audioDataR[i]/40.f) * 0xFF : 0;
			
			for( j = 0; j < 2; j++ )
			{
				data[4 * (x + y * 40) + 0] = grayL;
				data[4 * (x + y * 40) + 1] = grayL;		// try swap w grayR etc to highlight stereo
				data[4 * (x + y * 40) + 2] = grayL;
				
				y += 10;

				data[4 * (x + y * 40) + 0] = grayR;
				data[4 * (x + y * 40) + 1] = grayR;
				data[4 * (x + y * 40) + 2] = grayR;
				
				y += 10;
			}
		}
		
		// TODO some rendering options here
		//drawPosition = 0; // stay same
		//drawPosition++; // scroll
		drawPosition += toDraw;
		
		// get image ref and draw
		CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
		CGContextDrawImage(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), imageRef);
		CGImageRelease(imageRef);
	}
	else
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		CGContextSetRGBFillColor( context, 0, 0, 0, 1.f ); 
		CGContextFillRect(context, self.frame); 
	}
}

- (void) refresh
{
	[self update];
	[self setNeedsDisplay];
}

@end
