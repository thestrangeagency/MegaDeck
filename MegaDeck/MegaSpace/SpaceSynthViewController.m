//
//  SpaceSynthViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SpaceSynthViewController.h"
#import "MegaSpaceAppDelegate.h"

#define TOP_FRAME		48, 0, 224, 48
#define MAIN_FRAME		48, 48, 320-96, 480-96
#define SCULPT_FRAME	48, 48, 320-96, 480-48
#define BOTTOM_FRAME	48, 480-48, 224, 48

@implementation SpaceSynthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"SpaceSynthViewController viewDidLoad");
	
	synth = (SpaceSynthController *)[[MegaSpaceAppDelegate sharedAppDelegate] synth];
	
	if( !selectorView )
	{
		[[NSBundle mainBundle] loadNibNamed:@"ViewSelectorView" owner:self options:nil];
		[self.view addSubview:selectorView];
		[selectorView setFrame:CGRectMake(TOP_FRAME)];
	}
	
	if( !targetFader )
	{
		targetFader = [[MDXFade alloc] initWithFrame:CGRectMake(BOTTOM_FRAME)];
		[targetFader setDelegate:self];
		[targetFader setLabelAText:@"WAV1"];
		[targetFader setLabelBText:@"WAV2"];
		[self.view addSubview:targetFader];
	}
	
	[self showSpaceView];
	//[self showSculptA];
	
	// edit source button
	// [srcButton setTitle:@"LIB" forState:UIControlStateNormal];
	// hide source button
	[srcButton removeFromSuperview];

	// hide aux
	[auxButton removeFromSuperview];
	
	[self.view bringSubviewToFront:keyboardView];
	
	isExternal = NO;
	[(MegaSpaceAppDelegate*)[MegaSpaceAppDelegate sharedAppDelegate] checkForExistingScreenAndInitializeIfPresent];
}

- (void)dealloc 
{
    [spaceView release];
	[targetFader release];
	[screenInfoLabel release];
	[sculptA release];
	[sculptB release];
    [super dealloc];
}

/**
 * override to show library TODO
 */
- (IBAction)editSource:(id)sender 
{
	[[MDAppDelegate sharedAppDelegate] editSession];
}

- (void) refresh
{
	if( [[[MDAppDelegate sharedAppDelegate] sessionModel] isReady] )
		[recPanel setRecorded];
}

- (void) clearSpaceView
{
	if( spaceView.view.superview )
		[spaceView.view removeFromSuperview];
	[spaceView release];
	spaceView = nil;
}

- (void) displayInExternalWindow:(UIWindow*)window onScreen:(UIScreen*)screen
{	
	UIScreenMode *mode = [[screen availableModes] lastObject];
	CGSize screenSize = [mode size];
	
	[self clearSpaceView];
	spaceView = [[GLKSpaceViewController alloc] init];
	[spaceView.view setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
	[window addSubview:spaceView.view];
	
	if( !screenInfoLabel )
	{
		screenInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(48+8, 48+8, 224-8, 11)];
		[screenInfoLabel setFont:MD_FONT];
		[screenInfoLabel setTextColor:[UIColor whiteColor]];
		[screenInfoLabel setBackgroundColor:[UIColor blackColor]];
	}
	[screenInfoLabel setText:[NSString stringWithFormat:@"EXTERNAL %i x %i", (int)screenSize.width, (int)screenSize.height]];
	[self.view addSubview:screenInfoLabel];
	
	if( !proxyView )
	{
		proxyView = [[MDTouchProxyView alloc] initWithFrame:CGRectMake(MAIN_FRAME)];
		[proxyView setDelegate:spaceView];
	}
	[self.view addSubview:proxyView];
	
	isExternal = YES;
}

- (void) displayInDeviceWindow
{
	[screenInfoLabel removeFromSuperview];
	[proxyView removeFromSuperview];
	[self clearSpaceView];
	[self showSpaceView];
	
	isExternal = NO;
}

- (void) valueChanged:(MDControl*)control
{
	[synth setXFade:[(MDRibbon*)control value]];
}

- (float) getValue:(MDControl*)control
{
	return .5;
}

- (IBAction)onSelect:(id)sender
{
	if( sender == oscSelectButton )
	{
		[self showSpaceView];
	}
	else if( sender == t1SelectButton )
	{
		[self showSculptA];
	}
	else if( sender == t2SelectButton )
	{
		[self showSculptB];
	}
}

- (void) hideOther:(id)than
{
	if( !isExternal )
		[spaceView.view setHidden:spaceView == than ? NO : YES];
	[sculptA		setHidden:sculptA	== than ? NO : YES];
	[sculptB		setHidden:sculptB	== than ? NO : YES];
	
	[oscSelectButton setSelected:spaceView	!= than ? NO : YES];
	[t1SelectButton	 setSelected:sculptA	!= than ? NO : YES];
	[t2SelectButton	 setSelected:sculptB	!= than ? NO : YES];
	
	[keyboardView hide];
	[self.view bringSubviewToFront:keyboardView];
}

- (void) showSpaceView
{	
	if( !spaceView )
	{
		spaceView = [[GLKSpaceViewController alloc] init];
		[spaceView.view setFrame:CGRectMake(MAIN_FRAME)];
		[self.view addSubview:spaceView.view];
	}
	[self hideOther:spaceView];
}

- (void) showSculptA
{
	if( !sculptA )
	{
		sculptA = [[SpaceSculptView alloc] initWithFrame:CGRectMake(SCULPT_FRAME)];
		[sculptA setTarget:A];
		[self.view addSubview:sculptA];
	}
	[self hideOther:sculptA];
}

- (void) showSculptB
{
	if( !sculptB )
	{
		sculptB = [[SpaceSculptView alloc] initWithFrame:CGRectMake(SCULPT_FRAME)];
		[sculptB setTarget:B];
		[self.view addSubview:sculptB];
	}
	[self hideOther:sculptB];
}

@end
