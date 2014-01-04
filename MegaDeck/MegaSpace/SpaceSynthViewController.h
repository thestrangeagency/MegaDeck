//
//  SpaceSynthViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDSynthViewController.h"
#import "GLKSpaceViewController.h"
#import "MDXFade.h"
#import "MDInverseButton.h"
#import "SpaceSculptView.h"
#import "MDTouchProxyView.h"

@interface SpaceSynthViewController : MDSynthViewController <MDControlDelegate>
{
	GLKSpaceViewController *spaceView;
	MDXFade *targetFader;
	SpaceSynthController *synth;
	
	SpaceSculptView *sculptA;
	SpaceSculptView *sculptB;
	
	IBOutlet UIView *selectorView;
	IBOutlet MDInverseButton *oscSelectButton;
	IBOutlet MDInverseButton *t1SelectButton;
	IBOutlet MDInverseButton *t2SelectButton;
	
	UILabel *screenInfoLabel;
	BOOL isExternal;
	MDTouchProxyView *proxyView;
}

- (IBAction)onSelect:(id)sender;

- (void) showSpaceView;
- (void) showSculptA;
- (void) showSculptB;

- (void) displayInExternalWindow:(UIWindow*)window onScreen:(UIScreen*)screen;
- (void) displayInDeviceWindow;

// refresh when presenting again and viewDidLoad won't fire
- (void) refresh;

@end
