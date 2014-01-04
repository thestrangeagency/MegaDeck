//
//  SliceViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceViewController.h"
#import "MDAppDelegate.h"
#import "MegaSliceAppDelegate.h"
#import "SliceLoopView.h"
#import "SliceLoopModel.h"
#import "MDMixControlPanel.h"
#import "SliceSubLoopView.h"

#define BUTTON_SIZE			40
#define FADER_FRAME_INI		0, 0, 480-48*6, 40		// going to rotate this
#define FADER_FRAME			0, 48*3, 40, 480-48*6	// acutal frame
#define FADER_FRAME_OFF		-40, 48*3, 40, 480-48*6	// off screen hidden frame

@interface SliceViewController ()

- (void) showExtra:(BOOL)shouldShow;

@end

@implementation SliceViewController

@synthesize sliceController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"SliceViewController viewDidLoad");
	
	// synth = (SpaceSynthController *)[[MegaSpaceAppDelegate sharedAppDelegate] synth];
		
	if( !targetFader )
	{
		targetFader = [[MDXFade alloc] initWithFrame:CGRectMake(FADER_FRAME_INI)];
		[targetFader setDelegate:self];
		[targetFader setLabelAText:@"1"];
		[targetFader setLabelBText:@"2"];
		[self.view addSubview:targetFader];
		
		[targetFader setTransform:CGAffineTransformMakeRotation(M_PI_2)];
		[targetFader setFrame:CGRectMake(FADER_FRAME)];
	}
	
	// hide button
	[keyButton removeFromSuperview];
	
	// move SRC 1
	[srcButton setFrame:CGRectMake(0, 0, BUTTON_SIZE, BUTTON_SIZE)];
	
	// use aux for SRC 2
	[auxButton setTitle:@"SRC" forState:UIControlStateNormal];
	[auxButton setFrame:CGRectMake(0, self.view.bounds.size.height - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE)];
	[auxButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[auxButton addTarget:self action:@selector(editSource:) forControlEvents:UIControlEventTouchUpInside];
	
	// use mod for RESTART 1
	[modButton setTitle:@"R*" forState:UIControlStateNormal];
	[modButton setFrame:CGRectMake(0, 48, BUTTON_SIZE, BUTTON_SIZE)];
	[modButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[modButton addTarget:self action:@selector(restartLoop:) forControlEvents:UIControlEventTouchDown];
	[modButton setTag:0];
	
	// use env for RESTART 2
	[envButton setTitle:@"R*" forState:UIControlStateNormal];
	[envButton setFrame:CGRectMake(0, self.view.bounds.size.height - 88, BUTTON_SIZE, BUTTON_SIZE)];
	[envButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[envButton addTarget:self action:@selector(restartLoop:) forControlEvents:UIControlEventTouchDown];
	[envButton setTag:1];
	
	// bump up fx button
	[fxButton setFrame:CGRectMake(320-BUTTON_SIZE, 48, BUTTON_SIZE, BUTTON_SIZE)];
	
	// hide keyboard
	[keyboardView removeFromSuperview];
	
	// sub loop controls
	SliceSubLoopView *subView = [[SliceSubLoopView alloc] initWithFrame:CGRectMake(40, 0, 5*40, 16)];
	[subView setClipsToBounds:YES];
	[subView setLoop:[sliceController loop:0]];
	[self.view addSubview:subView];
	[subView release];
	
	subView = [[SliceSubLoopView alloc] initWithFrame:CGRectMake(40, 480-16, 5*40, 16)];
	[subView setClipsToBounds:YES];
	[subView setLoop:[sliceController loop:1]];
	[self.view addSubview:subView];
	[subView release];
	
	// loops
    loopViews = [[NSMutableArray alloc] initWithCapacity:2];
	
    SliceLoopView *loopView = [[SliceLoopView alloc] initWithFrame:CGRectMake(48, 16, 224, 224) loop:[sliceController loop:0]];
	[self.view addSubview:loopView];
    loopView.multipleTouchEnabled = YES;
    [loopViews addObject:loopView];
	[loopView release];

	loopView = [[SliceLoopView alloc] initWithFrame:CGRectMake(48, 240, 224, 224) loop:[sliceController loop:1]];
	[self.view addSubview:loopView];
    loopView.multipleTouchEnabled = YES;
    [loopViews addObject:loopView];
	[loopView release];
	
	// transport
	[[NSBundle mainBundle] loadNibNamed:@"MDTransportPanel" owner:self options:nil];
	[transport setFrame:CGRectMake(320-40, 192, 40, 88)];
	[self.view addSubview:transport];
	
	// extra controls
	extraView = [[SliceLoopExtraView alloc] initWithFrame:CGRectMake(FADER_FRAME)];
	[self.view addSubview:extraView];
	[self showExtra:NO];
	extraState = -1;
	
	// extra show buttons
	MDInverseButton *extraButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 96, 40, 40)];
	[extraButton addTarget:self action:@selector(onExtra:) forControlEvents:UIControlEventTouchUpInside];
	[extraButton setTag:0];
	[extraButton setTitle:@"→" forState:UIControlStateNormal];
	[self.view addSubview:extraButton];
	extraButtons = [[NSMutableArray arrayWithObject:extraButton] retain];
	[extraButton release];
	
	extraButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, 344, 40, 40)];
	[extraButton addTarget:self action:@selector(onExtra:) forControlEvents:UIControlEventTouchUpInside];
	[extraButton setTag:1];
	[extraButton setTitle:@"→" forState:UIControlStateNormal];
	[self.view addSubview:extraButton];
	[extraButtons addObject:extraButton];
	[extraButton release];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    for (int i = 0; i < loopViews.count; i++)
    {
        SliceLoopView *loopView = [loopViews objectAtIndex:i];
        [loopView killTouches];
    }
}

- (void)dealloc 
{
	[transport release];
	[targetFader release];
	[loopViews release];
	[sliceController release];
	[extraView release];
	[extraButtons release];
    [super dealloc];
}

- (IBAction)showPanel:(id)sender
{		
	[super showPanel:sender];

	// remove tremolo
	
	if( [panel isMemberOfClass:[MDMixControlPanel class]] )
	{
		[(MDMixControlPanel*)panel hideTremolo];
	}	

}

- (void) showExtra:(BOOL)shouldShow
{
	[UIView animateWithDuration:.1 
						  delay:0 
						options:UIViewAnimationOptionTransitionFlipFromLeft
					 animations:^{
						 extraView.frame = shouldShow ? CGRectMake(FADER_FRAME) : CGRectMake(FADER_FRAME_OFF);
					 } 
					 completion:^(BOOL finished) {
						 
					 }
	 ];
}

// --------------------------------------------------------------------------------
#pragma mark -

- (IBAction)restartLoop:(id)sender
{
	[[sliceController loop:[sender tag]] restart];
}

- (IBAction)editSource:(id)sender 
{
	if( sender == srcButton )
		[(MegaSliceAppDelegate*)[MDAppDelegate sharedAppDelegate] editSourceModel:[[sliceController loop:0] soundModel]];
	else if( sender == auxButton )
		[(MegaSliceAppDelegate*)[MDAppDelegate sharedAppDelegate] editSourceModel:[[sliceController loop:1] soundModel]];
}

- (void)onExtra:(id)sender
{
	int loopToShow = [sender tag];
	if( loopToShow == extraState )
	{
		// already showing, so hide
		[self showExtra:NO];
		extraState = -1;
		[[extraButtons objectAtIndex:loopToShow] setTitle:@"→" forState:UIControlStateNormal];
		[[extraButtons objectAtIndex:loopToShow] setSelected:NO];
	}
	else
	{
		// show
		[extraView setLoop:[sliceController loop:loopToShow]];
		[extraView setLoopView:[loopViews objectAtIndex:loopToShow]];
		[self showExtra:YES];
		extraState = loopToShow;
		[[extraButtons objectAtIndex:loopToShow] setTitle:@"←" forState:UIControlStateNormal];
		[[extraButtons objectAtIndex:loopToShow] setSelected:YES];
		[[extraButtons objectAtIndex:loopToShow == 0 ? 1 : 0] setTitle:@"→" forState:UIControlStateNormal];
		[[extraButtons objectAtIndex:loopToShow == 0 ? 1 : 0] setSelected:NO];
	}
}

- (void) refresh
{
	if( [[[MDAppDelegate sharedAppDelegate] sessionModel] isReady] )
		[recPanel setRecorded];
}

// --------------------------------------------------------------------------------
#pragma mark - MDControlDelegate

- (void) valueChanged:(MDControl*)control
{
	[sliceController setXFade:[(MDRibbon*)control value]];
}

- (float) getValue:(MDControl*)control
{
	return 0;
}

@end
