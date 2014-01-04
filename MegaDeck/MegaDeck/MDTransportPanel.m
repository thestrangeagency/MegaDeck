//
//  MDTransportPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/12/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDTransportPanel.h"

#define MAX_ELAPSED		3.0	// max seconds between beats i.e. 20 bpm is lowest tempo

@interface MDTransportPanel (/* private */)

@end

@implementation MDTransportPanel

// ----------------------------------------------------------------------- UIView
#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)coder 
{
    self = [super initWithCoder:coder];
    if (self)
	{
		transport = [[MDTransportModel sharedMDTransportModel] model];
		isTouch = NO;
		watch = [[LNCStopwatch alloc] init];
		[watch start];
		tapCount = 0;
		
		// if model is modified by another process
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:MD_TRANSPORT_NOTIFICATION object:nil];
    }
    return self;
}

- (void)dealloc
{
	[tempoLabel release];
	[toggleButton release];
    [super dealloc];
}

- (void) refresh
{
	[toggleButton setTitle:transport->isPlaying ? @"STOP" : @"PLAY" forState:UIControlStateNormal];
	[tempoLabel setText:[NSString stringWithFormat:@"%2.1f", transport->bpm]];
}

- (void) didMoveToSuperview
{
	[self refresh];
}

- (IBAction)togglePlay 
{
	transport->isPlaying = !transport->isPlaying;
	[self refresh];
}

// ----------------------------------------------------------------------- touches
#pragma mark touches

- (void)handleTouches:(NSSet *)touches
{	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	
	if( CGRectContainsPoint(CGRectMake(0, 0, 40, 40), location) )
		if( !isTouch )
		{
			isTouch = YES;
			iniLocation = location;
			iniBpm = transport->bpm;
		}
	
	// coarse Y
	float coarseAmount = iniLocation.y - location.y;
	if( isTouch && fabsf(coarseAmount) > 1.f )
	{
		transport->bpm = iniBpm + coarseAmount;
		// zero tap count if dragging
		tapCount = 0;
	}
	
	// fine X
	float fineAmount = iniLocation.x - location.x;
	if( isTouch && fabsf(fineAmount) > 10.f )
	{
		transport->bpm = iniBpm + coarseAmount + fineAmount/100.f;
		// zero tap count if dragging
		tapCount = 0;
	}

	[self refresh];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];

	tapCount++;
	double elapsed = [watch elapsedSeconds];
	[watch restart];
	
	// first tap
	if( elapsed > MAX_ELAPSED )
	{
		tapCount = 1;
	}
	
	// second tap
	if( tapCount == 2 )
	{
		elapsedAverage = elapsed;
	}
	// subsequent taps
	else
	{
		elapsedAverage = elapsed*.2 + elapsedAverage*.8;
	}
	// if more than 3 taps, set bpm (assuming 4/4)
	if( tapCount > 3 )
	{
		iniBpm = transport->bpm = 60.f / elapsedAverage;
	}
	
	// show tap mode
	if( tapCount > 1 )
	{
		[self setBackgroundColor:[UIColor colorWithWhite:MIN(4,tapCount)*.2 alpha:1.f]];
	
		[UIView animateWithDuration:MAX_ELAPSED 
							  delay:0.0 
							options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
						 animations:^ {
							 [self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:1.f]];
						 }
						 completion:^(BOOL finished) {
						 }];
	}
	
	NSLog(@"%i %2.2f %2.2f", tapCount, elapsed, elapsedAverage);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	isTouch = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}


@end
