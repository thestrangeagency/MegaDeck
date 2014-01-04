//
//  MegaSpaceAppDelegate.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MegaSpaceAppDelegate.h"
#import "SpaceSynthController.h"

@implementation MegaSpaceAppDelegate

@synthesize secondWindow = _secondWindow;
@synthesize spaceViewVontroller = _spaceViewVontroller;

- (void) initSynth
{
	synth = [[SpaceSynthController alloc] initWithVoiceCount:3];
	[synth attachToGraph:coreGraph];
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"YES",	@"color_wave_view",
								 @"YES",	@"trails_wave_view",
								 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
	[self setupScreenConnectionNotificationHandlers];
}

/**
 * override since this synth controller persists
 */
- (void) showSynth
{
	if( !_spaceViewVontroller)
		_spaceViewVontroller = [[SpaceSynthViewController alloc] initWithNibName:@"MDSynthViewController" bundle:[NSBundle mainBundle]];
	[self showChildView:_spaceViewVontroller];
	[_spaceViewVontroller refresh];
}

/**
 * override to keep space view around, since this app can has an external screen
 */
- (void) hideChildView
{
	[childViewController.view removeFromSuperview];
	if( childViewController != _spaceViewVontroller )
	{
		[childViewController release];
		childViewController = nil;
	}
}

- (void) checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
		UIScreen *newScreen = [[UIScreen screens] objectAtIndex:1];
		CGRect screenBounds = newScreen.bounds;
		
		if (!_secondWindow)
		{
			_secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
			_secondWindow.screen = newScreen;
		}
		
		// Set the initial UI for the window.
		[_spaceViewVontroller displayInExternalWindow:_secondWindow onScreen:newScreen];
		
		_secondWindow.hidden = NO;
	}
}
	
- (void) setupScreenConnectionNotificationHandlers
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	
    [center addObserver:self 
			   selector:@selector(handleScreenConnectNotification:)
				   name:UIScreenDidConnectNotification 
				 object:nil];
	
    [center addObserver:self 
			   selector:@selector(handleScreenDisconnectNotification:)
				   name:UIScreenDidDisconnectNotification 
				 object:nil];
}

- (void)handleScreenConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
    CGRect screenBounds = newScreen.bounds;
	
    if (!_secondWindow)
    {
        _secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        _secondWindow.screen = newScreen;
    }
	
	// Set the initial UI for the window.
	[_spaceViewVontroller displayInExternalWindow:_secondWindow onScreen:newScreen];

	_secondWindow.hidden = NO;
}

- (void)handleScreenDisconnectNotification:(NSNotification*)aNotification
{
	// Update the main screen based on what is showing here.
	[_spaceViewVontroller displayInDeviceWindow];
	
    if (_secondWindow)
    {
        // Hide and then delete the window.
        _secondWindow.hidden = YES;
        [_secondWindow release];
        _secondWindow = nil;
    }
}


@end
