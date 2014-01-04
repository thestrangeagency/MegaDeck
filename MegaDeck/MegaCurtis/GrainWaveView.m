//
//  GrainWaveView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainWaveView.h"
#import "MathUtil.h"
#import "GrainMidi.h"

@implementation GrainWaveView

@synthesize secondLocation, hasTouch, hasSecondTouch;

- (id)initWithFrame:(CGRect)frame 
{
	self = [super initWithFrame:frame];
    if (self) 
	{		
		[self setMultipleTouchEnabled:YES];
		
		hasTouch = NO;
		hasSecondTouch = NO;
		
		secondCursor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		[secondCursor setBackgroundColor:[UIColor clearColor]];
		[secondCursor setTextColor:[UIColor whiteColor]];
		[secondCursor setText:@"+"];
		[secondCursor setHidden:YES];
		[self addSubview:secondCursor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modWheel:) name:MIDI_MODWHEEL object:nil];
	}
	return self;
}

- (void)dealloc
{
	[secondCursor release];
	[firstTouch release];
    [super dealloc];
}

// ----------------------------------------------------------------------- midi
#pragma mark - midi

- (void) modWheel:(NSNotification*)notification
{
	[self setPositionFraction:[(NSNumber*)[[notification userInfo] objectForKey:@"value"] floatValue]];
	[delegate waveViewDidChange];
}

// ----------------------------------------------------------------------- properties
#pragma mark - properties

- (float) xFraction;
{
	return CLAMP(location.x / self.frame.size.width, 0.f, 1.f);
}

- (void) setXFraction:(float)fraction
{
	location.x = fraction * self.frame.size.width;
	[self updateCursor];
}

- (CGPoint) secondLocationDelta
{
	if( !hasSecondTouch )
		return CGPointZero;
	else
		return CGPointMake( secondLocation.x - secondLocationStart.x, secondLocation.y - secondLocationStart.y );
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{
	for( UITouch *touch in touches )
	{
		if( touch == firstTouch )
		{
//			NSLog(@"first");
			location = [touch locationInView:self];
			location.y = CLAMP(location.y, 0, self.bounds.size.height);
			[self updateCursor];
		}
		else
		{
//			NSLog(@"second");
			CGPoint secondLocationInView = [touch locationInView:self];
			secondLocationInView.y = CLAMP(secondLocationInView.y, 0, self.bounds.size.height);
			// normalize
			secondLocation = CGPointMake(secondLocationInView.x / self.bounds.size.width,
										 secondLocationInView.y / self.bounds.size.height);
			
			if( !hasSecondTouch )
			{
				NSLog(@"second start");
				hasSecondTouch = YES;
				secondLocationStart = secondLocation;
				[secondCursor setCenter:secondLocationInView];
				[secondCursor setHidden:NO];
			}
		}
	}
	
	// NSLog(@" (%.2f, %.2f), (%.2f, %.2f)", location.x, location.y, secondLocation.x, secondLocation.y);
	
	[delegate waveViewDidChange];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if( !firstTouch ) firstTouch = [[touches anyObject] retain];
	[self handleTouches:[event touchesForView:self]];
	hasTouch = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( [touches anyObject] == firstTouch ) 
	{
		[firstTouch release];
		firstTouch = nil;
	}
	else
	{
		hasSecondTouch = NO;
		[secondCursor setHidden:YES];
	}
	
	if ([touches count] == [[event touchesForView:self] count]) 
	{
        // last finger has lifted
		[firstTouch release];
		firstTouch = nil;
		hasTouch = NO;
    }
	
	[delegate waveViewDidChange];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
