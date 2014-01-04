//
//  MDAppDelegate.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/19/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MDSoundModel.h"
#import "MDSoundPlayer.h"
#import "MDSoundViewController.h"
#import "TSASynthController.h"
#import "TSACoreGraph.h"
#import "TSACoreGraphRecorder.h"
#import "TSASessionController.h"
#import "TSACoreFeedback.h"
#import "MDMidi.h"

@interface MDAppDelegate : UIResponder <UIApplicationDelegate, MDSoundViewControllerDelegate>
{
	UIViewController		*childViewController;
	
	TSACoreGraph			*coreGraph;
	TSASessionController	*session;
	
	MDSoundModel			*sourceModel;
	MDSoundModel			*sessionModel;
	
	MDSoundPlayer			*soundPlayer;
	TSACoreGraphRecorder	*inputRecorder;
	TSACoreGraphRecorder	*outputRecorder;
	
	TSASynthController		*synth;
	TSACoreFeedback			*echo;
	
	NSURL					*launchUrl;
	
	MDMidi					*midi;
}

@property (strong, nonatomic) UIWindow *window;

@property (retain) MDSoundModel		*sourceModel;
@property (retain) MDSoundModel		*sessionModel;
@property (retain) MDSoundPlayer	*soundPlayer;

@property (retain) TSACoreGraph			*graph;
@property (retain) TSACoreGraphRecorder *inputRecorder;
@property (retain) TSACoreGraphRecorder *outputRecorder;

@property (retain) TSASynthController	*synth;
@property (retain) TSACoreFeedback		*echo;

+ (MDAppDelegate*) sharedAppDelegate;

- (void) editSource;
- (void) editSession;
- (void) showSynth;

// is this a paid or free version
- (BOOL) isPaid;

// private
- (void) showChildView:(UIViewController*)viewController;

@end
