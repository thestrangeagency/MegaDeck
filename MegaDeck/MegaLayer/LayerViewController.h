//
//  SliceViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDSynthViewController.h"
#import "MDXFade.h"
#import "SliceController.h"
#import "MDTransportPanel.h"
#import "SliceLoopExtraView.h"

@interface LayerViewController : MDSynthViewController <MDControlDelegate>
{
	SliceController *sliceController;
    SliceLoopView	*loopView;
	NSMutableArray	*channelButtons;
	
	int				currentLoop;
	
	MDControl		*levelSlider;
	
	MDInverseButton *resetButton;
	MDInverseButton *clearButton;
	MDInverseButton *doubleButton;
	MDInverseButton *halfButton;
	MDInverseButton *muteButton;
	MDInverseButton *soloButton;
	
	IBOutlet MDTransportPanel *transport;
}

@property (retain) SliceController *sliceController;

// refresh when presenting again and viewDidLoad won't fire
- (void) refresh;

@end
