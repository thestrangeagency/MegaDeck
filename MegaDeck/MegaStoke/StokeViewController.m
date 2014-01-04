//
//  StokeViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeViewController.h"
#import "MDAppDelegate.h"
#import "MDHelpView.h"
#import "MegaStokeAppDelegate.h"

@implementation StokeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"StokeViewController viewDidLoad");
	
	if( !sequenceView )
	{
		sequenceView = [[StokeSequenceView alloc] init];
		[self.view addSubview:sequenceView];
	}
	
	// move up fx button
	// [fxButton setFrame:envButton.frame];
	
	// remove keyboard
	[keyboardView removeFromSuperview];
	
	// remove other buttons
	[srcButton removeFromSuperview];
	// [auxButton removeFromSuperview];
	// [envButton removeFromSuperview];
	[keyButton removeFromSuperview];
	
	[[NSBundle mainBundle] loadNibNamed:@"MDTransportPanel" owner:self options:nil];
	[transport setFrame:CGRectMake(0, 480-88, 40, 88)];
	[self.view addSubview:transport];

	// load from file
	[envButton setTitle:@"LOAD" forState:UIControlStateNormal];
	[envButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[envButton addTarget:self action:@selector(onLoadTouch) forControlEvents:UIControlEventTouchUpInside];
	
	// save to file
	[auxButton setTitle:@"SAVE" forState:UIControlStateNormal];
	[auxButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[auxButton addTarget:self action:@selector(onSaveTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void) refresh
{
	if( [[[MDAppDelegate sharedAppDelegate] sessionModel] isReady] )
		[recPanel setRecorded];
}

- (void) refreshPanel
{
	// reinit panel
	if( panel )
	{
		id temp = lastPanelSender;
		// same sender toggles panel off
		[self showPanel:lastPanelSender];
		// now show it again
		[self showPanel:temp];
	}
}

- (void) onSaveTouch
{
	[[(MegaStokeAppDelegate*)[MDAppDelegate sharedAppDelegate] stokeController] serialize];
}

- (void) onLoadTouch
{
	[[(MegaStokeAppDelegate*)[MDAppDelegate sharedAppDelegate] stokeController] unserialize];

	// refresh view
	[sequenceView removeFromSuperview];
	[sequenceView release];
	sequenceView = [[StokeSequenceView alloc] init];
	[self.view addSubview:sequenceView]; 
	
	[self.view bringSubviewToFront:transport];
}

- (void) dealloc 
{
    [sequenceView release];
    [super dealloc];
}

// ---------------------------------------------------------------------------------------------------- shake
#pragma mark - shake

- (void)showHelp
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:@"shake_for_help"] )
	{
		MDHelpView *helpView = [[MDHelpView alloc] initWithPlist:@"MegaStokeHelp"];
		[self.view addSubview:helpView];
		[helpView becomeFirstResponder];
		[helpView release];
	}
	else
	{
		NSLog(@"Help disabled");
	}
}

- (void)viewDidAppear:(BOOL)animated 
{
    [self becomeFirstResponder];
	
	// show help on appearing if help never shown before
	// TODO may need key for each view that has help
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownHelp"] )
	{
		[self showHelp];
	}
}

- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Shake!");
	[self showHelp];
}

@end
