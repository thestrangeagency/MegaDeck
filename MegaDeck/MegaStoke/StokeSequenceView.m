//
//  StokeSequenceView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeSequenceView.h"
#import "MegaStokeAppDelegate.h"
#import "MDInverseButton.h"

int stepOptions[] = {0,8,12,16,24};

enum slider
{
	VEL,
	DCY,
	NOTE,
	POS,
	LEVEL
};

@interface StokeSequenceView ()

- (void) layoutButtons;
- (void) layoutLoops;
- (void) onChannelTouch:(id)sender;
- (void) onModeTouch:(id)sender;

- (void) clearChannelButtons;
- (void) fadeLoops;
- (void) clearQuantizeButtons;
- (void) refreshModeControls;

- (void) selectEventView:(StokeEventView*)eventView;

@end

@implementation StokeSequenceView

- (id)init
{
	CGRect frame = CGRectMake(0, 0, 280, 480);
    self = [super initWithFrame:frame];
    if (self) 
	{
		modeNames = [[NSArray arrayWithObjects:
					 @"VEL", 
					 @"DCY", 
					 @"NOTE", 
					 @"POS", 
					 nil] retain];
		
        sequence = [[(MegaStokeAppDelegate*)[MegaStokeAppDelegate sharedAppDelegate] stokeController] sequence];

		[self layoutButtons];
		[self layoutLoops];
		[self selectEventView:nil];
		
		// init with first channel
		[self onChannelTouch:[channelButtons objectAtIndex:0]];
    }
    return self;
}

- (void)dealloc 
{
    [channelButtons removeAllObjects];
	[channelButtons release];
    [quantizeButtons removeAllObjects];
	[quantizeButtons release];
	[modeButtons removeAllObjects];
	[modeButtons release];	
	[loopViews removeAllObjects];
	[loopViews release];
	[modeNames release];
	[modeControls release];
	[modeHandle release];
	[muteButton release];
	[probButton release];
	[levelSlider release];
    [super dealloc];
}

- (void) layoutLoops
{
	int count = [sequence voiceCount];
	if( loopViews )
		[loopViews removeAllObjects];
	else
		loopViews = [[NSMutableArray alloc] initWithCapacity:count];
	for( int i=0; i<count; i++ )
	{
		StokeLoopView *loopView = [[StokeLoopView alloc] initWithLoop:[[sequence channelAtIndex:i] loop]];
		[loopViews addObject:loopView];
		[self addSubview:loopView];
		[loopView setDelegate:self];
		[loopView release];
	}
}

- (void) layoutButtons
{
	// channel buttons
	
	int count = [sequence voiceCount];
	if( channelButtons ) 
		[channelButtons removeAllObjects];
	else
		channelButtons = [[NSMutableArray alloc] initWithCapacity:count];
	for( int i=0; i<count; i++ )
	{
		MDInverseButton *button = [[MDInverseButton alloc] initWithFrame:CGRectMake(0, i*48, 40, 40)];
		[button setTag:i];
		[button setTitle:[NSString stringWithFormat:@"C%i",i] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(onChannelTouch:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[channelButtons addObject:button];
	}
	
	// src button
	
	MDInverseButton *button = [[MDInverseButton alloc] initWithFrame:CGRectMake(40, 0, 40, 40)];
	[button setTitle:@"SRC" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(onSrcTouch) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
	[button release];
	
	// mute button
	
	muteButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+48, 48, 40, 40)];
	[muteButton setTitle:@"MUTE" forState:UIControlStateNormal];
	[muteButton addTarget:self action:@selector(onMuteTouch:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:muteButton];
	
	// prob button
	
	probButton = [[MDInverseButton alloc] initWithFrame:CGRectMake(88+96, 48, 40, 40)];
	[probButton setTitle:@"PROB" forState:UIControlStateNormal];
	[probButton addTarget:self action:@selector(onProbTouch:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:probButton];
	
	// quantize buttons
	
	if( quantizeButtons ) 
		[quantizeButtons removeAllObjects];
	else
		quantizeButtons = [[NSMutableArray alloc] initWithCapacity:count];
	for( int i=0; i<5; i++ )
	{
		MDInverseButton *button = [[MDInverseButton alloc] initWithFrame:CGRectMake((i>0)?40 + i*48:88, (i>0)?96:48, 40, 40)];
		[button setTag:i];
		[button setTitle:[NSString stringWithFormat:@"1/%i",stepOptions[i]] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(onQuantizeTouch:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		[quantizeButtons addObject:button];
		[button release];
	}
	
	// handle
	
	modeHandle = [[UIView alloc] initWithFrame:CGRectMake(88, 3*48, 4*48-8, 88)];
	[self addSubview:modeHandle];
	
	// mode buttons
	
	if( modeButtons ) 
		[modeButtons removeAllObjects];
	else
		modeButtons = [[NSMutableArray alloc] initWithCapacity:count];
	for( int i=0; i<[modeNames count]; i++ )
	{
		MDInverseButton *button = [[MDInverseButton alloc] initWithFrame:CGRectMake(i*48, 0, 40, 40)];
		[button setTag:i];
		[button setTitle:[modeNames objectAtIndex:i] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(onModeTouch:) forControlEvents:UIControlEventTouchUpInside];
		[modeHandle addSubview:button];
		[modeButtons addObject:button];
		[button release];
	}
	
	// mode controls
	
	CGRect controlFrame = CGRectMake(0, 48, 144, 40);
	
	if( modeControls ) 
		[modeControls removeAllObjects];
	else
		modeControls = [[NSMutableArray alloc] initWithCapacity:count];
	
	MDControlSlider *modeControl = [[MDControlSlider alloc] initWithFrame:controlFrame];
	[modeControl setTaper:audio];
	[modeControl setLabelText:@"EVENT VELOCITY"];
	[modeControl setTag:VEL];
	[modeControl setDelegate:self];
	[modeHandle addSubview:modeControl];
	[modeControls addObject:modeControl];
	[modeControl release];
	
	modeControl = [[MDControlSlider alloc] initWithFrame:controlFrame];
	[modeControl setTaper:linear];
	[modeControl setLabelText:@"EVENT DECAY"];
	[modeControl setTag:DCY];
	[modeControl setDelegate:self];
	[modeHandle addSubview:modeControl];
	[modeControls addObject:modeControl];
	[modeControl release];
	
	modeControl = [[MDControlSlider alloc] initWithFrame:controlFrame];
	[modeControl setTaper:linear];
	[modeControl setLabelText:@"EVENT NOTE"];
	[modeControl setTag:NOTE];
	[modeControl setDelegate:self];
	[modeHandle addSubview:modeControl];
	[modeControls addObject:modeControl];
	[modeControl release];
	
	modeControl = [[MDControlSlider alloc] initWithFrame:controlFrame];
	[modeControl setTaper:linear];
	[modeControl setLabelText:@"EVENT POSITION"];
	[modeControl setTag:POS];
	[modeControl setDelegate:self];
	[modeHandle addSubview:modeControl];
	[modeControls addObject:modeControl];
	[modeControl release];
	
	// channel level
	
	levelSlider = [[MDControlSlider alloc] initWithFrame:CGRectMake(88, 0, 144, 40)];
	[levelSlider setTaper:audio];
	[levelSlider setLabelText:@"LEVEL"];
	[levelSlider setTag:LEVEL];
	[levelSlider setDelegate:self];
	[self addSubview:levelSlider];
}

// ---------------------------------------------------------------------------------------------------- clear
#pragma mark - clear

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

- (void) clearQuantizeButtons
{
	[self clearButtonsIn:quantizeButtons];
}

- (void) clearModeButtons
{
	[self clearButtonsIn:modeButtons];
}

- (void) hideModeControls
{
	for( UIView *control in modeControls )
	{
		[control setHidden:YES];
	}
}

- (void) refreshModeControls
{
	for( MDControl *control in modeControls )
	{
		[control refresh];
	}
}

- (void) fadeLoops
{
	for( StokeLoopView *loopView in loopViews )
	{
		[loopView setAlpha:.2];
		[loopView setNeedsDisplay];
	}
}

// ---------------------------------------------------------------------------------------------------- button handlers
#pragma mark - button handlers

- (void) onChannelTouch:(id)sender
{
	int index = [(UIButton*)sender tag];
	NSLog(@"Select channel: %i", index);
	channel = [sequence channelAtIndex:index];
	[self clearChannelButtons];
	[sender setSelected:YES];

	// deselect last top loop events
	[topLoopView deselectAll];
	
	// bring view to front, fade others
	[self fadeLoops];
	topLoopView = [loopViews objectAtIndex:index];
	topLoop = [topLoopView loop];
	[self bringSubviewToFront:topLoopView];
	[topLoopView setAlpha:1.f];
	[topLoopView setNeedsDisplay];
	
	// find and select quantize button
	[self clearQuantizeButtons];
	int steps = [topLoopView quantize];
	int i;
	for( i=0; i<5; i++ ){ if( stepOptions[i] == steps ) break; }
	[[quantizeButtons objectAtIndex:i] setSelected:YES];
	
	// select synth channel
	[(MegaStokeAppDelegate*)[MDAppDelegate sharedAppDelegate] selectChannel:index];
	
	// deselect loop events
	[topLoopView deselectAll];
	[self selectEventView:nil];
	
	// default mode
	[self onModeTouch:[modeButtons objectAtIndex:0]];
	
	// loop mode buttons
	[muteButton setSelected:topLoop.isMuted];
	[probButton setSelected:topLoop.isProbable];
	
	// refresh level
	[levelSlider refresh];
}

- (void) onSrcTouch
{
	[(MegaStokeAppDelegate*)[MegaStokeAppDelegate sharedAppDelegate] editSourceModel:[channel soundModel]];
}

- (void) onMuteTouch:(id)sender
{
	[topLoop setIsMuted:!topLoop.isMuted];
	[muteButton setSelected:topLoop.isMuted];
}

- (void) onProbTouch:(id)sender
{
	[topLoop setIsProbable:!topLoop.isProbable];
	[probButton setSelected:topLoop.isProbable];	
}

- (void) onQuantizeTouch:(id)sender
{
	int index = [(UIButton*)sender tag];
	NSLog(@"Select quantize: %i = 1/%i", index, stepOptions[index]);
	// quantize loop, quantize existing items if this button is already selected, i.e. on second tap
	[topLoopView setQuantize:stepOptions[index] updateExisting:[(UIButton*)sender isSelected] ? YES : NO];
	[self clearQuantizeButtons];
	[sender setSelected:YES];
}

- (void) onModeTouch:(id)sender
{
	int index = [(UIButton*)sender tag];
	NSLog(@"Select mode: %i", index);
	[self clearModeButtons];
	[sender setSelected:YES];
	
	// controls (Vel Decay Note Pos)
	
	if( index < [modeControls count] )
	{
		MDControlSlider* modeControl = (MDControlSlider*)[modeControls objectAtIndex:index];	
		[self hideModeControls];
		[modeControl setHidden:NO];
	}
}

// ----------------------------------------------------------------------- touch
#pragma mark - touch

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self selectEventView:nil];
	[topLoopView deselectAll];
}

// ----------------------------------------------------------------------- selection
#pragma mark - selection

- (void) selectEventView:(StokeEventView*)eventView
{
	if( eventView )
	{
		selectedEventView = eventView;
		selectedEvent = [selectedEventView event];
		[self refreshModeControls];
		
		modeHandle.alpha = 1.f;
		[modeHandle setUserInteractionEnabled:YES];
	}
	else
	{
		selectedEventView = nil;
		selectedEvent = nil;
		
		modeHandle.alpha = 0.1;
		[modeHandle setUserInteractionEnabled:NO];
	}
}

// ----------------------------------------------------------------------- slice delegate
#pragma mark - loop delegate

- (void) imageDidSelect:(InteractiveImage*)newlySelectedImage
{
	[self selectEventView:(StokeEventView*)newlySelectedImage];
}

// --------------------------------------------------------------------------------
#pragma mark - MDControlDelegate

- (void) valueChanged:(MDControl*)control
{
	if( selectedEvent == NULL && [control tag] != LEVEL ) return;
	
	float value = [(MDControlSlider*)control value];
	
	switch ([control tag])
	{
		case VEL:
			// set event velocity
			selectedEvent->velocity = value;
			break;
		
		case DCY:
			// set event decay
			selectedEvent->decay = value;
			break;
		
		case NOTE:
			// set event note
			selectedEvent->noteNumber = value;
			break;
			
		case POS:
			// set event position
			selectedEvent->grainStart = value;
			break;
			
		case LEVEL:
			// set channel level
			channel.level = value;
			break;
			
		default:
			break;
	}
	
	[selectedEventView refresh];
}

- (float) getValue:(MDControl*)control
{
	if( selectedEvent == NULL && [control tag] != LEVEL ) return 0;
	
	switch ([control tag])
	{
		case VEL:
			// get event velocity
			return selectedEvent->velocity;
			break;
		
		case DCY:
			// get event decay
			return selectedEvent->decay;
			break;

		case NOTE:
			// get event note
			return selectedEvent->noteNumber;
			break;
			
		case POS:
			// get event position
			return selectedEvent->grainStart;
			break;
		
		case LEVEL:
			// get channel level
			return channel.level;
			break;
			
		default:
			return 0;
			break;
	}
}

@end
