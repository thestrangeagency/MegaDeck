//
//  MDTransportPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/12/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDLabel.h"
#import "MDTransportModel.h"
#import "LNCStopwatch.h"

@interface MDTransportPanel : UIView
{
	TransportModel *transport;
	
	IBOutlet MDLabel	*tempoLabel;
	IBOutlet UIButton	*toggleButton;
	
	BOOL	isTouch;
	CGPoint	iniLocation;
	float	iniBpm;
	
	LNCStopwatch *watch;
	int tapCount;
	double elapsedAverage;
}

- (IBAction)togglePlay;

@end
