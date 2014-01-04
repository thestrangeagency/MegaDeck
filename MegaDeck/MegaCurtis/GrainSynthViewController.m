//
//  GrainSynthViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainSynthViewController.h"
#import "MegaCurtisAppDelegate.h"
#import "MDModControlPanel.h"
#import "TSACoreGraph+Control.h"
#import "MathUtil.h"

#import "GrainControlGroup.h"
#import "GrainKeyControlGroup.h"
#import "GrainPosControlPanel.h"
#import "GrainProControlPanel.h"

@implementation GrainSynthViewController

// ---------------------------------------------------------------------------------------------------- state
#pragma mark - state

- (void) serialize
{
	NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:[self portraitOrientation]], @"portrait", nil];
	[[NSUserDefaults standardUserDefaults] setObject:state forKey:@"GrainSynthViewController"];	
}

- (void) unserialize
{
	NSDictionary *state = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"GrainSynthViewController"];
	if( state )
	{
		[self setPortraitOrientation:[[state objectForKey:@"portrait"] boolValue]];
	}
}

// ---------------------------------------------------------------------------------------------------- view
#pragma mark - view

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSLog(@"GrainSynthViewController viewDidLoad");
	
	synth = (GrainSynthController*)[[MegaCurtisAppDelegate sharedAppDelegate] synth];
	graph = [[MDAppDelegate sharedAppDelegate] graph];
	
	if( !waveView )
	{
		waveView = [[GrainWaveView alloc] initWithFrame:CGRectMake(48, 0, 224, 480)];
		[waveView setShouldZoomToSelection:YES];
		[waveView setSoundModel:[[MegaCurtisAppDelegate sharedAppDelegate] sourceModel]];
		[waveView setDelegate:self];
		[self.view addSubview:waveView];
	}
	
	if( !infoView )
	{
		[[NSBundle mainBundle] loadNibNamed:@"GrainInfoView" owner:self options:nil];
		[self.view addSubview:infoView];
		[infoView setFrame:CGRectMake(48, 0, 224, 120)];
		[infoView hideBLabels:YES];
	}
	
	if( !keyView )
	{
		keyView = [[GrainKeyView alloc] initWithFrame:CGRectMake(48, 40, 224, 440)];
		[keyView setDelegate:self];
		[keyView setIsPrettyChromatic:NO];
		[keyView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
		[keyView setKeyAlpha:.4];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(soundDidLoad:) 
												 name:FILE_LOADED 
											   object:nil];
	
	[self.view bringSubviewToFront:keyboardView];
	
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	
	// playthru mode doesn't use wave view for interaction, just visuals
	if( [[[MDAppDelegate sharedAppDelegate] inputRecorder] isPlaythrough] )
	{
		[waveView setCursorHidden:YES];
		[waveView setUserInteractionEnabled:NO];
		[infoView setHidden:YES];
	}
	else
	{
		[waveView setCursorHidden:NO];
		[waveView setUserInteractionEnabled:YES];
	}
	
	useXPitch = [[NSUserDefaults standardUserDefaults] boolForKey:@"portrait_x_pitch"];
	
	// set auxilliary button and panel
	if( [[MDAppDelegate sharedAppDelegate] isPaid] )
	{
		[auxButton setTitle:@"POS" forState:UIControlStateNormal];
		auxPanelClass = [GrainPosControlPanel class];
	}
	else
	{
		[auxButton setTitle:@"PRO" forState:UIControlStateNormal];
		auxPanelClass = [GrainProControlPanel class];
		// place just above src button
		CGRect frame = [srcButton frame];
		frame.origin.y -= 48;
		[auxButton setFrame:frame];
	}
	
	[self unserialize];
}

- (void)cleanup
{
	[self serialize];
	
	[waveView release];
	waveView = nil;
	[infoView release];	
	infoView = nil;
	[keyView release];
	keyView = nil;
	[group release];
	group = nil;
	[graph release];
	graph = nil;
	[displayLink invalidate];
	displayLink = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self serialize];
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

// ---------------------------------------------------------------------------------------------------- view updates
#pragma mark - view updates

-(void) soundDidLoad:(NSNotification*)note
{
	NSLog(@"GrainSynthViewController noticed new file loaded");
	
	[waveView reset];
	[waveView setPositionFraction:[synth position]];
}

- (IBAction)showPanel:(id)sender
{		
	[super showPanel:sender];
	
	if( [[MDAppDelegate sharedAppDelegate] isPaid] )
	{
		// add auxiliary controls
		
		if( [panel isMemberOfClass:[MDModControlPanel class]] )
		{
			group = [[GrainControlGroup alloc] initWithPanel:panel];
		}
		else if( [panel isMemberOfClass:[MDKeyControlPanel class]] )
		{
			group = [[GrainKeyControlGroup alloc] initWithPanel:panel];
			[(GrainKeyControlGroup*)group setController:self];
		}
	}
}

- (void) updateDisplay:(CADisplayLink *)sender
{	
	if( [[[MDAppDelegate sharedAppDelegate] inputRecorder] isPlaythrough] )
	{
		[waveView refresh];
	}
	else
	{
		if( [self portraitOrientation] )
			[infoView refresh];
		else
			[keyView refresh];
	}
}

- (BOOL) portraitOrientation
{
	return [waveView portraitOrientation];
}

-(void) setPortraitOrientation:(BOOL)portrait
{
	[waveView setPortraitOrientation:portrait];
	if( portrait )
	{
		[infoView setHidden:NO];
		[keyView removeFromSuperview];
	}
	else
	{
		[infoView setHidden:YES];
		[self.view addSubview:keyView];
		[self.view bringSubviewToFront:panel];
		[self.view bringSubviewToFront:keyboardView];
	}
}

// ---------------------------------------------------------------------------------------------------- touch
#pragma mark - touch

- (void) handlePortraitTouch
{
	if( useXPitch )
	{
		if( [waveView hasTouch] )
			[synth noteGlide:(int)([waveView xFraction]*128.f)];
		else
			[synth noteGlideCancel];
	}
	else
		[graph setFilterCutoff:lin2exp([waveView xFraction])];
	
	[infoView setAX:[waveView xFraction]];
	[infoView setCenter:CGPointMake(160, CLAMP(roundf([waveView positionFraction]*480), 60, 420))];
		
	if( !hasSecondTouch && [waveView hasSecondTouch] )
	{
		iniPeriod = [synth startModPeriod];
		iniDepth = [synth startModDepth];
	}
	
	hasSecondTouch = [waveView hasSecondTouch];
	
	if( hasSecondTouch )
	{
		float period = iniPeriod - [waveView secondLocationDelta].x;
		period = CLAMP(period, 0.f, 1.f);
		[infoView setBX:1.f - period];
		[synth setStartModPeriod:period];
		
		float depth = iniDepth - [waveView secondLocationDelta].y;
		depth = CLAMP(depth, 0.f, 1.f);
		[infoView setBY:depth];
		[synth setStartModDepth:depth];
		
		[infoView hideBLabels:NO];		
	}
	else
	{
		[infoView hideBLabels:YES];
	}
}

- (void) handleLandscapeTouch
{
	// in landscape mode the keyboard overlay intercepts all touches (below y=40)
	// this is for touches 0<=y<40, sets all views to same position
	[keyView setCenter:CGPointMake(keyView.frame.size.width * [waveView positionFraction], -99.f)];
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

// ---------------------------------------------------------------------------------------------------- MDWaveViewControllerDelegate
#pragma mark - MDWaveViewControllerDelegate

- (void) waveViewDidChange
{
	[synth setPosition:[waveView positionFraction]];
	
	if([waveView portraitOrientation])
		[self handlePortraitTouch];
	else
		[self handleLandscapeTouch];
}

@end
