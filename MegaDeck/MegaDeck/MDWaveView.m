
#import "MDWaveView.h"

@implementation MDWaveView

@synthesize soundModel, shouldZoomToSelection, shouldUseWaveView;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
        audioData = (SInt16 *)malloc( sizeof(SInt16)*MAX(PORTRAIT_DRAW_SAMPLES, LANDSCAPE_DRAW_SAMPLES) );
		shouldZoomToSelection = NO;
		isPortrait = YES;
		
		[self setBackgroundColor:[UIColor blackColor]];
		
		shouldUseWaveView = [[NSUserDefaults standardUserDefaults] boolForKey:@"use_wave_view"];
    }
    return self;
}

- (void) setSoundModel:(MDSoundModel *)model
{
	soundModel = [model retain];
	[self update];
}

- (void) setShouldUseWaveView:(BOOL)_shouldUseWaveView
{
	shouldUseWaveView = _shouldUseWaveView;
	[self update];
}

- (void) update
{
	int samples = isPortrait ? PORTRAIT_DRAW_SAMPLES : LANDSCAPE_DRAW_SAMPLES;
	
	float step = shouldZoomToSelection ? (float)[soundModel start] : 0;
	float stepSize = shouldZoomToSelection ? (float)[soundModel length] / samples : (float)[soundModel frameCount] / samples;
	
	if( soundModel.audioBuffer->mNumberChannels == 2 )
	{
		// stereo
		
		UInt32 *frameBuffer = (UInt32 *)soundModel.audioBuffer->mData;
		SInt16* left;
		SInt16* right;
		
		for(int i=0; i<samples; i++)
		{			
			left = (SInt16*)&frameBuffer[ (int)round(step) ];
			right = left+1;
			
			audioData[i] = (*left + *right)/2;
			step += stepSize;
		}
	}
	else if( soundModel.audioBuffer->mNumberChannels == 1 )
	{
		// mono
		
		SInt16 *frameBuffer = (SInt16 *)soundModel.audioBuffer->mData;
		
		for(int i=0; i<samples; i++)
		{			
			audioData[i] = frameBuffer[ (int)round(step) ];
			step += stepSize;
		}
	}
}

- (void)drawRect:(CGRect)rect 
{
	if( soundModel.isReady )
	{
		int samples = isPortrait ? PORTRAIT_DRAW_SAMPLES : LANDSCAPE_DRAW_SAMPLES;
		float scale = .5; // = 1.f / [[UIScreen mainScreen] scale];
		
		CGFloat width = self.bounds.size.width;
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetRGBStrokeColor( context, 1, 1, 1, 1.f );
		CGContextSetLineWidth( context, scale );
		CGContextSetShouldAntialias( context, NO );
		
		if( shouldUseWaveView )
		{
			// original drawing method
			
			CGFloat waveMiddle = self.bounds.size.width/2;
						
			for( int i=0; i<samples; i++)
			{
				float y = i*scale;
				
				CGContextMoveToPoint(context, waveMiddle, y);
				
				SInt16 sample = audioData[i];
				CGFloat amplitude = waveMiddle * (float)sample / 32768.0;
				CGContextAddLineToPoint(context, waveMiddle + amplitude, y);
			}
			
			CGContextStrokePath(context);
		}
		else
		{
			// amp to gray method
			
			for( int i=0; i<samples; i++)
			{
				float y = i*scale;
				
				CGContextBeginPath(context);
				CGContextMoveToPoint(context, 0, y);
				
				SInt16 sample = audioData[i];
				CGFloat amplitude = .5 + (float)sample / 65536.0f;
				CGContextSetRGBStrokeColor( context, amplitude, amplitude, amplitude, 1.f );
				CGContextAddLineToPoint(context, width, y);
				CGContextStrokePath(context);
			}
		}
	}
	else
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		CGContextSetRGBFillColor( context, 0, 0, 0, 1.f ); 
		CGContextFillRect(context, self.bounds); 
	}
}

- (BOOL) portraitOrientation
{
	return isPortrait;
}

-(void) setPortraitOrientation:(BOOL)portrait
{
	if( portrait != isPortrait )
	{
		isPortrait = portrait;
		CGRect frame = self.frame;
		[self setTransform: isPortrait ? CGAffineTransformMakeRotation(0) : CGAffineTransformMakeRotation(-M_PI_2)];
		[self setFrame:frame];
		[self refresh];
	}
}

- (void) refresh
{
	[self update];
	[self setNeedsDisplay];
}

- (void) animate
{
	if( !displayLink )
	{
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
		[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	}
	else
	{
		[self pause:NO];
	}
}

- (void) updateDisplay:(CADisplayLink *)sender
{
	[self refresh];
}

- (void) pause:(BOOL)shouldPause
{
	[displayLink setPaused:shouldPause];
}

- (void) dealloc
{
	[displayLink invalidate];
	[soundModel release];
	free(audioData);
    [super dealloc];
}


@end
