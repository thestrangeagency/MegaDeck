//
//  MDKeyboardView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/4/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDKeyboardView.h"
#import "MDAppDelegate.h"
#import "MDKeyModel.h"

// only show keyboard animation first time
static BOOL shown = NO;
// maintain showing state
static BOOL isShowing = YES;

// ----------------------------------------------------------------------------------------------------

@interface MDKeyboardView ( /* private */ )

- (void)showOctave;
- (void)showPitch:(int)noteNumber;

@end

// ----------------------------------------------------------------------------------------------------

@implementation MDKeyboardView

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)coder 
{
    self = [super initWithCoder:coder];
    if (self) 
	{
		delegate = [[MDAppDelegate sharedAppDelegate] synth];
		
		keyView = [[MDKeyView alloc] initWithFrame:CGRectMake(0, 40, 120, 440)];
		[keyView setDelegate:self];
		[self addSubview:keyView];
    }
    return self;
}

- (void) showKeys:(BOOL)animated
{
	if( isShowing ) [[NSNotificationCenter defaultCenter] postNotificationName:KEYBOARD_SHOWING object:self];
	
	float destX = isShowing ? 60 : 60-80;
	if( animated )
		[UIView animateWithDuration:.5
					 animations:^{ 
						 [self setCenter:CGPointMake(destX, self.center.y)];
					 }];
	else
		[self setCenter:CGPointMake(destX, self.center.y)];
}

- (void)didMoveToSuperview
{
	[self showOctave];
	if( !shown )
	{
		isShowing = NO;
		shown = YES;
		[self showKeys:YES];
	}
	else
	{
		[self showKeys:NO];
	}
}

- (void)dealloc 
{
	[noteLabel release];
	[delegate release];
	[super dealloc];
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

// ---------------------------------------------------------------------------------------------------- buttons
#pragma mark - buttons

- (IBAction)shiftUp
{
	[[MDKeyModel sharedMDKeyModel] shiftUp];
	[self showOctave];
}

- (IBAction)shiftDown
{
	[[MDKeyModel sharedMDKeyModel] shiftDown];
	[self showOctave];	
}

- (IBAction)toggleShowing
{
	isShowing = !isShowing;
	[self showKeys:YES];
}

- (void) hide
{
	if( isShowing ) [self toggleShowing];
}

@end
