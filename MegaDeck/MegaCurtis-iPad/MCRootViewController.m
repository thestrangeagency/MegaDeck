//
//  MCRootViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/17/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MCRootViewController.h"
#import "MCAppDelegate.h"

@implementation MCRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		synth = (GrainSynthController*)[[MCAppDelegate sharedAppDelegate] synth];
		recorder = [[MDAppDelegate sharedAppDelegate] outputRecorder];
    }
    return self;
}

- (void)dealloc 
{
	[synth release];
	[recorder release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];

	controlPanel = [[MCControlPanel alloc] initWithFrame:CGRectMake(56, 8, 368, 184)];
	[self.view addSubview:controlPanel];
	
	waveView = [[MCWaveView alloc] initWithFrame:CGRectMake(0, 200, 704, 784)];
	[waveView setSoundModel:[[MCAppDelegate sharedAppDelegate] sourceModel]];
	[self.view addSubview:waveView];
	[waveView animate];
	
	keyboardView = [[MCKeyboardView alloc] initWithFrame:CGRectMake(0, 1024-40, 768, 40)];
	[self.view addSubview:keyboardView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(soundDidLoad:) 
												 name:FILE_LOADED 
											   object:nil];
	
	soundView = [[MCSoundViewController alloc] initWithModel:[[MCAppDelegate sharedAppDelegate] sourceModel] player:[[MCAppDelegate sharedAppDelegate] soundPlayer]];
	[self.view addSubview:soundView.view];
	[soundView.view setFrame:CGRectMake(768-56, 0, 56, 1024-40)];
	
	keyView = [[MDKeyView alloc] initWithFrame:waveView.frame];
	[keyView setDelegate:self];
	[keyView setIsPrettyChromatic:NO];
	[keyView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
	[keyView setKeyAlpha:.1];
	[self.view addSubview:keyView];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

// ---------------------------------------------------------------------------------------------------- view updates
#pragma mark - view updates

-(void) soundDidLoad:(NSNotification*)note
{
	NSLog(@"MCRootViewController noticed new file loaded");

	[waveView refresh];
}

// ---------------------------------------------------------------------------------------------------- keyProtocol
#pragma mark - keyProtocol

- (void) notePressed:(int)noteNumber withVelocity:(float)velocity
{
	[keyboardView notePressed:noteNumber withVelocity:velocity];
	[synth setPosition:velocity];
}

- (void) noteReleased:(int)noteNumber
{
	[keyboardView noteReleased:noteNumber];
}

- (void) afterTouch:(int)noteNumber withVelocity:(float)velocity
{
	[synth setPosition:velocity forNote:noteNumber];
}

// ---------------------------------------------------------------------------------------------------- MDSoundViewControllerDelegate
#pragma mark - MDSoundViewControllerDelegate

- (void) soundViewController:(MDSoundViewController*)viewController didEdit:(MDSoundModel*)soundModel
{
	[waveView refresh];
}

// ---------------------------------------------------------------------------------------------------- MDRecPanelDelegate
#pragma mark - MDRecPanelDelegate

- (void) recPanelStart
{
	//[srcButton setHidden:YES];
	[recorder prepareRecording];
	[recorder startRecording];
}

- (UInt32) framesRecorded
{
	return [recorder framesRecorded];
}

- (void) recPanelStop
{
	//[srcButton setHidden:NO];
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
