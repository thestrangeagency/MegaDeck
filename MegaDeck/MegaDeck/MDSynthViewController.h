//
//  MDSynthViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/4/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDKeyboardView.h"
#import "TSASynthProtocol.h"
#import "MDRecPanel.h"
#import "TSACoreGraphRecorder.h"
#import "MDControlPanel.h"
#import "MDKeyControlPanel.h"

@interface MDSynthViewController : UIViewController <MDRecPanelDelegate>
{
	IBOutlet MDKeyboardView *keyboardView;
	IBOutlet MDRecPanel *recPanel;
	IBOutlet MDKeyControlPanel *keyPanel;

	IBOutlet UIButton *mixButton;
	IBOutlet UIButton *modButton;
	IBOutlet UIButton *envButton;
	IBOutlet UIButton *fxButton;
	IBOutlet UIButton *keyButton;
	IBOutlet UIButton *auxButton;
	IBOutlet UIButton *srcButton;
		
	TSACoreGraphRecorder *recorder;
	MDControlPanel *panel;
	id lastPanelSender;
	Class auxPanelClass;
}

- (IBAction)showPanel:(id)sender;
- (IBAction)hidePanel:(id)sender;
- (IBAction)editSource:(id)sender;


@end
