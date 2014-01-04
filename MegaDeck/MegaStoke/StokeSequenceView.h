//
//  StokeSequenceView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StokeSequence.h"
#import "StokeChannel.h"
#import "StokeLoopView.h"
#import "MDControl.h"
#import "StokeLoop.h"
#import "InteractiveImageDelegate.h"
#import "StokeEventView.h"
#import "StokeLoop.h"
#import "MDInverseButton.h"

@interface StokeSequenceView : UIView <MDControlDelegate,InteractiveImageDelegate>
{
	StokeSequence	*sequence;
	StokeChannel	*channel;
	
	NSMutableArray	*channelButtons;
	NSMutableArray	*quantizeButtons;

	UIView			*modeHandle;
	NSArray			*modeNames;
	NSMutableArray	*modeButtons;
	NSMutableArray	*modeControls;

	NSMutableArray	*loopViews;

	StokeLoopView	*topLoopView;
	StokeLoop		*topLoop;
	StokeEventView	*selectedEventView;
	StokeEvent		*selectedEvent;
	
	MDInverseButton *muteButton;
	MDInverseButton *probButton;
	MDControl		*levelSlider;
}
@end
