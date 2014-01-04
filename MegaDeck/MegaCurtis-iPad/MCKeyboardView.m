//
//  MCKeyboardView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/17/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MCKeyboardView.h"
#import "MCAppDelegate.h"

// ----------------------------------------------------------------------------------------------------

@interface MCKeyboardView ( /* private */ )

- (void)showOctave;
- (void)showPitch:(int)noteNumber;

@end

// ----------------------------------------------------------------------------------------------------

@implementation MCKeyboardView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		delegate = [[MCAppDelegate sharedAppDelegate] synth];
		
		keyView = [[MDKeyView alloc] initWithFrame:CGRectMake(0, 0, 704, 40)];
		[keyView setDelegate:self];
		[self addSubview:keyView];
    }
    return self;
}

// ---------------------------------------------------------------------------------------------------- keyProtocol
#pragma mark keyProtocol

- (void) notePressed:(int)noteNumber withVelocity:(float)velocity
{
	[delegate notePressed:noteNumber];
	[self showPitch:noteNumber];
}

- (void) noteReleased:(int)noteNumber
{
	[delegate noteReleased:noteNumber];
}

- (void) afterTouch:(int)noteNumber withVelocity:(float)velocity
{
	// ignore
}

// ---------------------------------------------------------------------------------------------------- label
#pragma mark label

- (void)showOctave
{	
	[noteLabel setText:[NSString stringWithFormat:@"OCT %i", [[MDKeyModel sharedMDKeyModel] baseOctave]]];
}

- (void)showPitch:(int)noteNumber
{	
	int octave = noteNumber / 12;
	[noteLabel setText:[NSString stringWithFormat:@"%@ %i", 
						[[MDKeyModel sharedMDKeyModel] noteNameWithNoteNumber:noteNumber],
						octave]];
}


@end
