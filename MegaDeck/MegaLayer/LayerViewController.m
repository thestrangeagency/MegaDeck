//
//  SliceViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "LayerViewController.h"
#import "MDAppDelegate.h"
#import "MegaLayerAppDelegate.h"
#import "SliceLoopView.h"
#import "SliceLoopModel.h"
#import "MDMixControlPanel.h"
#import "SliceSubLoopView.h"

#define BUTTON_SIZE			40

@interface LayerViewController ()

- (void) showChannelState;

@end

@implementation LayerViewController

@synthesize sliceController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"LayerViewController viewDidLoad");
		
	// hide buttons
	[keyButton removeFromSuperview];
	[auxButton removeFromSuperview];
	[envButton removeFromSuperview];
	
	// move SRC 1
	[srcButton setFrame:CGRectMake(BUTTON_SIZE, 0, BUTTON_SIZE, BUTTON_SIZE)];
	
	// level
	levelSlider = [[MDControlSlider alloc] initWithFrame:CGRectMake(88, 0, 144, 40)];
	[levelSlider setTaper:audio];
	[levelSlider setLabelText:@"LEVEL"];
	[levelSlider setDelegate:self];
	[self.view addSubview:levelSlider];
	
	// use mod for RESTART 1
	[modButton setTitle:@"R*" forState:UIControlStateNormal];
	[modButton setFrame:CGRectMake(BUTTON_SIZE, 48, BUTTON_SIZE, BUTTON_SIZE)];
	[modButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[modButton addTarget:self action:@selector(restartLoop:) forControlEvents:UIControlEventTouchDown];
	[modButton setTag:0];
	
	resetButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88, 48, BUTTON_SIZE, BUTTON_SIZE)];
	[resetButton addTarget:self action:@selector(onReset) forControlEvents:UIControlEventTouchUpInside];
	[resetButton setTitle:@"RST" forState:UIControlStateNormal];
	[self.view addSubview:resetButton];
	
	clearButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88, 48+48, BUTTON_SIZE, BUTTON_SIZE)];
	[clearButton addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
	[clearButton setTitle:@"CLR" forState:UIControlStateNormal];;
	[self.view addSubview:clearButton];
	
	doubleButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+48, 48, BUTTON_SIZE, BUTTON_SIZE)];
	[doubleButton addTarget:self action:@selector(onDouble) forControlEvents:UIControlEventTouchUpInside];
	[doubleButton setTitle:@"x2" forState:UIControlStateNormal];
	[self.view addSubview:doubleButton];
	
	halfButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+48, 48+48, BUTTON_SIZE, BUTTON_SIZE)];
	[halfButton addTarget:self action:@selector(onHalf) forControlEvents:UIControlEventTouchUpInside];
	[halfButton setTitle:@"/2" forState:UIControlStateNormal];
	[self.view addSubview:halfButton];

	muteButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+48+48, 48, BUTTON_SIZE, BUTTON_SIZE)];
	[muteButton addTarget:self action:@selector(onMute) forControlEvents:UIControlEventTouchUpInside];
	[muteButton setTitle:@"MUTE" forState:UIControlStateNormal];
	[self.view addSubview:muteButton];
	
	soloButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+48+48, 48+48, BUTTON_SIZE, BUTTON_SIZE)];
	[soloButton addTarget:self action:@selector(onSolo) forControlEvents:UIControlEventTouchUpInside];
	[soloButton setTitle:@"SOLO" forState:UIControlStateNormal];
	[self.view addSubview:soloButton];
	
	// bump up fx button
	[fxButton setFrame:CGRectMake(320-BUTTON_SIZE, 48, BUTTON_SIZE, BUTTON_SIZE)];
	
	// hide keyboard
	[keyboardView removeFromSuperview];
	
	// sub loop controls
	/*
	 SliceSubLoopView *subView = [[SliceSubLoopView alloc] initWithFrame:CGRectMake(40, 480-16, 5*40, 16)];
	[subView setClipsToBounds:YES];
	[subView setLoop:[sliceController loop:0]];
	[self.view addSubview:subView];
	[subView release];
	*/
	
	// loops
    loopView = [[SliceLoopView alloc] initWithFrame:CGRectMake(48, 240, 224, 224) loop:[sliceController loop:0]];
	[self.view addSubview:loopView];
    loopView.multipleTouchEnabled = YES;
	
	// transport
	[[NSBundle mainBundle] loadNibNamed:@"MDTransportPanel" owner:self options:nil];
	[transport setFrame:CGRectMake(320-40, 192, 40, 88)];
	[self.view addSubview:transport];
	
	// channel buttons
	
	if( channelButtons ) 
		[channelButtons removeAllObjects];
	else
		channelButtons = [[NSMutableArray alloc] initWithCapacity:LAYERS];
	for( int i=0; i<LAYERS; i++ )
	{
		MDInverseButton *button = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, i*48, 40, 40)];
		[button setTag:i];
		[button setTitle:[NSString stringWithFormat:@"L%i",i] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(onChannelTouch:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
		[channelButtons addObject:button];

        // select first button
        if (i == 0)
            [button setSelected:YES];
	}
	
	// since we pre-mute some channels
	[self showChannelState];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
	[loopView killTouches];
}

- (void)dealloc 
{
	[transport release];
	[loopView release];
	[sliceController release];
	[channelButtons release];
	[levelSlider setDelegate:nil];
	
	[levelSlider release];
	[resetButton release];
	[clearButton release];
	[doubleButton release];
	[halfButton release];
	[muteButton release];
	[soloButton release];
	
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

// --------------------------------------------------------------------------------
#pragma mark -

// reset slice order
- (void) onReset
{
	[loopView resetSlices];
}

// unmute all slices
- (void) onClear
{
	[loopView unmuteAll];
}

// double speed
- (void) onDouble
{
	[[sliceController loop:currentLoop] doubleSpeed];
}

// half speed
- (void) onHalf
{
	[[sliceController loop:currentLoop] halveSpeed];
}

- (void) onMute
{
	if( [muteButton isSelected] )
	{
		[sliceController unmute:currentLoop];
		[muteButton setSelected:NO];
	}
	else
	{
		[sliceController mute:currentLoop];
		[muteButton setSelected:YES];
	}
	
	[self showChannelState];
}

- (void) onSolo
{
	if( [soloButton isSelected] )
	{
		[sliceController unsolo];
		[soloButton setSelected:NO];
	}
	else
	{
		[sliceController solo:currentLoop];
		[soloButton setSelected:YES];
		
		if( [muteButton isSelected] )
		{
			[sliceController unmute:currentLoop];
			[muteButton setSelected:NO];
		}
	}
	
	[self showChannelState];
}

// --------------------------------------------------------------------------------
#pragma mark -

- (void) showChannelState
{
	for( MDInverseButton *button in channelButtons )
	{
		if( [sliceController isMuted:[button tag]] )
		{
			[button setTitle:[NSString stringWithFormat:@"L%i.M",[button tag]] forState:UIControlStateNormal];
		}
		else
		{
			[button setTitle:[NSString stringWithFormat:@"L%i",[button tag]] forState:UIControlStateNormal];
		}
		
		NSString *file = [[[sliceController lastPath:[button tag]] lastPathComponent] uppercaseString];
		[button addLabelText:file];
	}
}

- (void) clearButtonsIn:(NSArray*)buttons
{
	for( MDInverseButton *button in buttons )
	{
		[button setSelected:NO];
	}
}

- (void) clearChannelButtons
{
	[self clearButtonsIn:channelButtons];
}

- (void) onChannelTouch:(id)sender
{
	currentLoop = [(UIButton*)sender tag];
	NSLog(@"Select channel: %i", currentLoop);
	
	// show selection
	[self clearChannelButtons];
	[sender setSelected:YES];
	
	// refresh buttons
	[muteButton setSelected:[sliceController isMuted:currentLoop] ? YES : NO];
	[soloButton setSelected:[sliceController isSolo:currentLoop] ? YES : NO];
		
	// refresh level
	[levelSlider refresh];
	
	// refresh loop view
	[loopView setModel:[sliceController loop:currentLoop]];
	
	// TODO let sub loop controller know channel change
	// [subView setLoop:[sliceController loop:currentLoop]];
}

// --------------------------------------------------------------------------------
#pragma mark -

- (IBAction)restartLoop:(id)sender
{
	[[sliceController loop:currentLoop] restart];
}

- (IBAction)editSource:(id)sender 
{
	[(MegaLayerAppDelegate*)[MDAppDelegate sharedAppDelegate] editSourceModel:[[sliceController loop:currentLoop] soundModel]];
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
	[sliceController setLevel:[(MDRibbon*)control value] forLoop:currentLoop];
}

- (float) getValue:(MDControl*)control
{
	return [sliceController levelForLoop:currentLoop];
}

@end
