//
//  StokeSequencer.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	this implementation didn't work out so well
//  timing was uneven and beats were skipped
//	decided to integrate sequencing directly into a synth voice subclass
//
//	DO NOT USE!

#import "TSACoreGraph.h"
#import "StokeController.h"

@interface StokeSequencer : NSObject
{
	StokeController *stokeController;
	
	double hTime2nsFactor;
    float loopNanos;
	
	float start;
	float end;
	
    pthread_t thread;
}

- (id) initWithController:(StokeController*)stokeController;

@end
