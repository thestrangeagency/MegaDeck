//
//  MDSoundViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/21/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//
//  Use to view and interact with a SoundModel

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "MDSoundModel.h"
#import "MDSoundPlayer.h"
#import "MDWaveTrimView.h"
#import "TSADocumentsViewController.h"
#import "MDPasteBoardViewController.h"
#import "TSACoreGraphRecorder.h"

#if TARGET_NAME == MegaCurtis_iPad
	#define WAVE_TRIM_RECT	0, 200, 56, 784
#else
	#define WAVE_TRIM_RECT	48, 0, 224, 480
#endif

// -----------------------------------------------------------------------

@class MDSoundViewController;

@protocol MDSoundViewControllerDelegate <NSObject>

- (void) soundViewController:(MDSoundViewController*)viewController didEdit:(MDSoundModel*)soundModel;

@end

// -----------------------------------------------------------------------

@interface MDSoundViewController : UIViewController <UIActionSheetDelegate, TSADocumentsViewControllerDelegate, MDWaveViewDelegate, MFMailComposeViewControllerDelegate>
{
	MDSoundModel			*soundModel;
	MDSoundPlayer			*soundPlayer;
	MDWaveTrimView			*waveTrimView;
	
	UIActionSheet			*actionsSheet;
	UIViewController		*ioViewController;
	
	id<MDSoundViewControllerDelegate> delegate;
	
	NSString				*tempCopyPath;
	
	TSACoreGraphRecorder	*recorder;
	
	IBOutlet UILabel		*nameLabel;
	IBOutlet UILabel		*timeLabel;
	IBOutlet UILabel		*startLabel;
	IBOutlet UILabel		*endLabel;
	
	IBOutlet UIButton		*playButton;
	IBOutlet UIButton		*stopPlayButton;
	IBOutlet UIButton		*recordButton;
	IBOutlet UIButton		*stopRecordButton;
	IBOutlet UIButton		*throughButton;
	
	IBOutlet UIButton		*xferButton;
	IBOutlet UIButton		*okButton;
	
	IBOutlet UIView			*recordView;
	
	NSTimer					*recordingTimer;
	
	BOOL					canRead;
}

@property (retain) id<MDSoundViewControllerDelegate> delegate;

- (id) initWithModel:(MDSoundModel*)model player:(MDSoundPlayer*)player;

- (IBAction) play;
- (IBAction) stopPlay;
- (IBAction) record;
- (IBAction) stopRecord;
- (IBAction) through;
- (IBAction) action;
- (IBAction) ok;

// protected
- (void) soundDidLoad;
- (void) updateTrimLabels;

@end
