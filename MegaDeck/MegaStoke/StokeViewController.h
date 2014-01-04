//
//  StokeViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDSynthViewController.h"
#import "StokeSequenceView.h"
#import "MDTransportPanel.h"

@interface StokeViewController : MDSynthViewController
{
	StokeSequenceView	*sequenceView;
	IBOutlet MDTransportPanel *transport;
}

// refresh when presenting again and viewDidLoad won't fire
- (void) refresh;

// refresh when channel i.e. synth changes
- (void) refreshPanel;

@end
