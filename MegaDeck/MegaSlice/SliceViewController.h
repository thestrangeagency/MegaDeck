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

@interface SliceViewController : MDSynthViewController <MDControlDelegate>
{
	MDXFade *targetFader;
	SliceController *sliceController;
    NSMutableArray *loopViews;
	
	IBOutlet MDTransportPanel *transport;
	
	SliceLoopExtraView *extraView;
	int extraState;	// 0 or 1 if showing, -1 if not
	NSMutableArray *extraButtons;
}

@property (retain) SliceController *sliceController;

// refresh when presenting again and viewDidLoad won't fire
- (void) refresh;

@end
