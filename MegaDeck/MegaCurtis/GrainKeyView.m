//
//  GrainKeyView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/25/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainKeyView.h"
#import "GrainVectorView.h"
#import "GrainSynthController.h"
#import "MDAppDelegate.h"
#import "MathUtil.h"

@implementation GrainKeyView

- (void) initVoiceViews
{
	GrainSynthController *synth = (GrainSynthController*)[[MDAppDelegate sharedAppDelegate] synth];
	
	voiceViews = [[NSMutableArray arrayWithCapacity:synth.voices.count] retain];
	
	CGRect rect = CGRectMake(0, 0, 20, 20);
	for (GrainVoiceController *voice in synth.voices) 
	{
		GrainVectorView *grainView = [[GrainVectorView alloc] initWithFrame:rect];
		grainView.grainVoice = voice.grainVoice;
		[voiceViews addObject:grainView];
		[self addSubview:grainView];
		[grainView setHidden:YES];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[MDKeyView sharedTouchHandler:self];
		[self initVoiceViews];
		[self keyChanged];
	}
	return self;
}

- (void)dealloc
{
	[voiceViews release];	
    [super dealloc];
}

- (void) refresh
{
	if( voiceViews )
		for( GrainVectorView *grainView in voiceViews )
		{
			[grainView refresh];
		}
}

// ---------------------------------------------------------------------------------------------------- MDKeyModel
#pragma mark - MDKeyModel notification

- (void)keyChanged
{
	[super keyChanged];

	for( GrainVectorView *grainView in voiceViews )
	{
		[grainView setFrame:CGRectMake(0, 0, keyHeight, keyHeight - 1.f)]; // -1 to compensate for lines between keys
		[grainView setHidden:YES];
	}
}

// ---------------------------------------------------------------------------------------------------- highlight
#pragma mark - highlight

- (void) setCenter:(CGPoint)center
{
	// don't move touch is outside
	BOOL isOutsideX = center.x < 0 ? YES : NO;
	BOOL isOutsideY = center.y < 0 ? YES : NO;
	
	center.x = CLAMP(center.x, keyHeight/2, self.bounds.size.width - keyHeight/2);
	center.y = keyHeight/2 + keyHeight * floorf(center.y / keyHeight) - .5f; // -.5 to compensate for lines between keys
	
	for( GrainVectorView *grainView in voiceViews )
	{
		if( isOutsideX ) center.x = grainView.center.x;
		if( isOutsideY ) center.y = grainView.center.y;
		[grainView setCenter:center];
		[grainView setHidden:NO];
	}
}

- (void) setCenter:(CGPoint)center forNote:(int)noteNumber
{
	// don't move touch is outside, ie if coming from another keyview
	BOOL isOutsideX = center.x < 0 ? YES : NO;
	BOOL isOutsideY = center.y < 0 ? YES : NO;
	
	center.x = CLAMP(center.x, keyHeight/2, self.bounds.size.width - keyHeight/2);
	center.y = keyHeight/2 + keyHeight * floorf(center.y / keyHeight) - .5f; // -.5 to compensate for lines between keys
	
	for( GrainVectorView *grainView in voiceViews )
	{
		if( grainView.grainVoice->superVoice->noteNumber == noteNumber )
		{
			if( isOutsideX ) center.x = grainView.center.x;
			if( isOutsideY ) center.y = grainView.center.y;
			[grainView setCenter:center];
			[grainView setHidden:NO];
			[self bringSubviewToFront:grainView];
			break;
		}
	}
}

- (void)handleSharedTouches:(NSSet*)touches
{
	for( UITouch *touch in touches )
	{
		[self setCenter:[touch locationInView:self] 
				forNote:[self noteNumberForTouch:touch]];
	}
}

@end
