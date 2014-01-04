//
//  MDWaveCursorView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDWaveCursorView.h"
#import "MDWaveView.h"
#import "MathUtil.h"

@implementation MDWaveCursorView

@synthesize delegate, isLive;

- (void) updateCursor
{
	cursor.center = CGPointMake(cursor.center.x, location.y);
}

- (void) setCursorHidden:(BOOL)shouldHide
{
	[cursor setHidden:shouldHide];
}

- (void) setSoundModel:(MDSoundModel *)model
{
	[soundModel release];
	soundModel = [model retain];
	[self reset];
}

- (void) updateDisplay:(CADisplayLink *)sender
{
	if( !soundModel.isReady ) return;
	
	[self setPositionFraction:[delegate positionFraction]];
	
	if( isLive )
	{
		[self refresh];
	}
}

// ----------------------------------------------------------------------- UIView
#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame 
{
	self = [super initWithFrame:frame];
    if (self) 
	{		
		isLive = NO;
		
		cursor = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, .5)];
		[self addSubview:cursor];
		[cursor setBackgroundColor:[UIColor whiteColor]];
		[cursor setUserInteractionEnabled:NO];
		
		activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
		
		[self setMultipleTouchEnabled:NO];
		[self reset];
	}
    return self;
}

- (void) dealloc
{
	[soundModel release];
	[activityView release];
	[delegate release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	
	location = [touch locationInView:self];
	location.y = CLAMP(location.y, 0, self.bounds.size.height);
	[self updateCursor];
	
	[delegate waveViewDidChange];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

// ----------------------------------------------------------------------- public
#pragma mark - public

-(void) setPortraitOrientation:(BOOL)portrait
{
	CGRect frame = [cursor frame];
	[super setPortraitOrientation:portrait];
	[cursor setFrame:CGRectMake(frame.origin.x, frame.origin.y, self.bounds.size.width, frame.size.height)];
	location.y = CLAMP(location.y, 0, self.bounds.size.height);
	[self updateCursor];
}

-(void) suspend
{
	[self setUserInteractionEnabled:NO];
	[activityView startAnimating];
}

-(void) reset
{
	if( soundModel && soundModel.isReady )
	{				
		// load audio into wave view
		[self refresh];
		
		// update views
		[self setPositionFraction:.5];
		[activityView stopAnimating];
		
		// listen for touches
		[self setUserInteractionEnabled:YES];
	}
	else
	{
		[self suspend];
	}
}

- (float) positionFraction;
{
	return location.y / self.bounds.size.height;
}

- (void) setPositionFraction:(float)fraction
{
	location.y = fraction * self.bounds.size.height;
	[self updateCursor];
}

@end

