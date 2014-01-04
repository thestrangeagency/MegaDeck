//
//  MDRecPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/31/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNCStopwatch.h"

@protocol MDRecPanelDelegate <NSObject>

- (void) recPanelStart;
- (void) recPanelStop;
- (void) recPanelEdit;
- (void) recPanelClear;
- (UInt32) framesRecorded;

@end

enum PanelState 
{
	IDLE,
	RECORDING,
	RECORDED
};

@interface MDRecPanel : UIView
{
	IBOutlet UIButton *aButton;
	IBOutlet UIButton *bButton;
	int state;
	
	NSTimer *recordingTimer;
	
	id<MDRecPanelDelegate> delegate;
}

@property (retain) id delegate;

- (IBAction) touchUpInside:(id)sender;

- (void) startRecording;
- (void) stopRecording;
- (void) setRecorded;

@end
