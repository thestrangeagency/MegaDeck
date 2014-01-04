//
//  MDSynthViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/4/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#define PANEL_RECT		48, 0, 224, 480

#import "MDSynthViewController.h"
#import "MDAppDelegate.h"
#import "MDMixControlPanel.h"
#import "MDEnvelopeControlPanel.h"
#import "MDFxControlPanel.h"
#import "MDModControlPanel.h"
#import "MDKeyControlPanel.h"

@implementation MDSynthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		recorder = [[MDAppDelegate sharedAppDelegate] outputRecorder];
		auxPanelClass = NULL;
	}
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[recPanel setDelegate:self];
	if( [[[MDAppDelegate sharedAppDelegate] sessionModel] isReady] )
		[recPanel setRecorded];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(hidePanel) 
												 name:KEYBOARD_SHOWING 
											   object:nil];
	
	if( ![[MDAppDelegate sharedAppDelegate] isPaid] )
	{
		// bump up key button
		[keyButton setFrame:[fxButton frame]];
		
		// free version typically has no FX and no recording
		[fxButton removeFromSuperview];
		[recPanel removeFromSuperview];
	}
}

- (void)cleanup
{
	[keyboardView release];
	keyboardView = nil;
    
	[mixButton release];
    mixButton = nil;
    [modButton release];
    modButton = nil;
	[envButton release];
    envButton = nil;
	[fxButton release];
    fxButton = nil;
	[keyButton release];
	keyButton = nil;
	[auxButton release];
	auxButton = nil;
	
	[recPanel release];
	recPanel = nil;
	[srcButton release];
	srcButton = nil;
	[keyPanel release];
	keyPanel = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[[MDAppDelegate sharedAppDelegate] synth] panic];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[[MDAppDelegate sharedAppDelegate] synth] panic];
}

- (void)viewDidUnload
{
	[self cleanup];
	[super viewDidUnload];
}

- (void)dealloc 
{
	[self cleanup];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (IBAction)showPanel:(id)sender 
{
	[self hidePanel:sender];
	
	// same button toggles
	if( sender == lastPanelSender )
	{
		lastPanelSender = nil;
		return;
	}
	
	[sender setSelected:YES];
	lastPanelSender = sender;
	
	// new button creates new panel
	if( sender == mixButton )
	{
		panel = [MDMixControlPanel alloc];
	}
	else if( sender == modButton )
	{
		panel = [MDModControlPanel alloc];
	}
	else if( sender == envButton )
	{
		panel = [MDEnvelopeControlPanel alloc];
	}
	else if( sender == fxButton )
	{
		panel = [MDFxControlPanel alloc];
	}
	else if( sender == keyButton )
	{
		// this panel lives in a nib, so requires special loading
		[[NSBundle mainBundle] loadNibNamed:@"MDKeyControlPanel" owner:self options:nil];
		[self.view addSubview:keyPanel];
		[keyPanel setFrame:CGRectMake(PANEL_RECT)];
		panel = keyPanel;
	}
	else if( sender == auxButton )
	{
		if( auxPanelClass )
			panel = [auxPanelClass alloc];
	}
	
	// all other panels just get an init
	if( sender != keyButton )
		[self.view addSubview:[panel initWithFrame:CGRectMake(PANEL_RECT)]];
	[self.view bringSubviewToFront:keyboardView];
	[keyboardView hide];
}

- (IBAction)editSource:(id)sender 
{
	[[MDAppDelegate sharedAppDelegate] editSource];
}

- (IBAction)hidePanel:(id)sender
{
	[panel removeFromSuperview];
	panel = nil;
	[lastPanelSender setSelected:NO];
}

- (void)hidePanel
{
	[self hidePanel:nil];
	lastPanelSender = nil;
}

// ---------------------------------------------------------------------------------------------------- MDRecPanelDelegate
#pragma mark - MDRecPanelDelegate

- (void) recPanelStart
{
	[srcButton setHidden:YES];
	[recorder prepareRecording];
	[recorder startRecording];
}

- (UInt32) framesRecorded
{
	return [recorder framesRecorded];
}

- (void) recPanelStop
{
	[srcButton setHidden:NO];
	[recorder stopRecording];
	[recorder flush];
}

- (void) recPanelEdit
{
	[[MDAppDelegate sharedAppDelegate] editSession];
}

- (void) recPanelClear
{
	[[[MDAppDelegate sharedAppDelegate] sessionModel] clear];
}

@end
