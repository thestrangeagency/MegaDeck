//
//  MCRootViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/17/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrainSynthController.h"
#import "MDKeyView.h"
#import "MCKeyboardView.h"
#import "TSACoreGraphRecorder.h"
#import "MDRecPanel.h"
#import "MCSoundViewController.h"
#import "MCWaveView.h"
#import "MCControlPanel.h"

@interface MCRootViewController : UIViewController <MDSoundViewControllerDelegate,MDKeyProtocol>
{
	GrainSynthController	*synth;
	MCControlPanel			*controlPanel;

	MCSoundViewController	*soundView;
	MCWaveView				*waveView;
	MDKeyView				*keyView;
	MCKeyboardView			*keyboardView;
	
	TSACoreGraphRecorder	*recorder;
	MDRecPanel				*recPanel;
}
@end
