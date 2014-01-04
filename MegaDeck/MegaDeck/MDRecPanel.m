//
//  MDRecPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/31/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDRecPanel.h"

@interface MDRecPanel (/* private */)

- (void) setState:(int)newState;
- (void) updateButtons;
- (void) updateTime:(NSTimer*)theTimer;
- (void) startTimer;
- (void) stopTimer;

@end

@implementation MDRecPanel

@synthesize delegate;

// ----------------------------------------------------------------------- UIView
#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)coder 
{
    self = [super initWithCoder:coder];
    if (self)
	{
        [self setState:IDLE];
    }
    return self;
}

- (void)dealloc
{
	[aButton release];
	[bButton release];
	[recordingTimer invalidate];
	[recordingTimer release];
	[delegate release];
    [super dealloc];
}

// ----------------------------------------------------------------------- state control
#pragma mark - state control

- (void) startRecording
{
	if( state == IDLE )
	{
		[self setState:RECORDING];
		[self startTimer];
	}
}

- (void) stopRecording
{
	if( state == RECORDING )
	{
		[self setState:RECORDED];
		[self stopTimer];
	}
}

- (void) setRecorded
{
	[self setState:RECORDED];
}

- (void) setState:(int)newState
{
	state = newState;
	[self updateButtons];
}

// ----------------------------------------------------------------------- ui
#pragma mark - ui

- (IBAction) touchUpInside:(id)sender
{
	if( sender == aButton )
	{
		if( state == IDLE )
		{
			// empty
		}
		else if( state == RECORDING )
		{
			// time display
		}
 		else if( state == RECORDED )
		{
			// clear button
			[self setState:IDLE];
			[delegate recPanelClear];
		}
	}
	else if( sender == bButton )
	{
		if( state == IDLE )
		{
			// rec button
			[self startRecording];
			[delegate recPanelStart];
		}
		else if( state == RECORDING )
		{
			// stop button
			[self stopRecording];
			[delegate recPanelStop];
		}
 		else if( state == RECORDED )
		{
			// edit button
			[self setState:IDLE];
			[delegate recPanelEdit];
		}	
	}
}

- (void) updateButtons
{
	if( state == IDLE )
	{
		[aButton setHidden:YES];
		
		[bButton setTitle:@"REC" forState:UIControlStateNormal];
	}
	else if( state == RECORDING )
	{
		[aButton setHidden:NO];
		[aButton setTitle:@"00:00" forState:UIControlStateNormal];
		[aButton setEnabled:NO];
		
		[bButton setTitle:@"STOP" forState:UIControlStateNormal];
	}
	else if( state == RECORDED )
	{
		[aButton setHidden:NO];
		[aButton setTitle:@"CLEAR" forState:UIControlStateNormal];
		[aButton setEnabled:YES];
		
		[bButton setTitle:@"EDIT" forState:UIControlStateNormal];
	}
}

// ----------------------------------------------------------------------- timer
#pragma mark - timer

- (void) startTimer
{
	recordingTimer = [[NSTimer scheduledTimerWithTimeInterval: 1.0 
													   target: self 
													 selector: @selector(updateTime:) 
													 userInfo: nil 
													  repeats: YES] 
					  retain];
}

- (void) stopTimer
{
	[recordingTimer invalidate];
	[recordingTimer release];
	recordingTimer = nil;
}

- (void) updateTime:(NSTimer*)theTimer
{
	UInt32 frames = [delegate framesRecorded];
	int seconds = frames / 44100.f;
	int minutes = floorf( seconds / 60.0f );
	seconds = roundf( seconds % 60 );
	[aButton setTitle:[NSString stringWithFormat:@"%02i:%02i", minutes, seconds] 
			 forState:UIControlStateNormal];
	// safety
	if( minutes > 60 ) [self stopRecording];
}

@end
