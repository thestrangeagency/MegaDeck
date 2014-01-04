//
//  MDMidi.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PGMidi;
@class TSASynthController;
@class TSACoreGraph;
@class LNCStopwatch;
@class TSACoreFeedback;

@interface MDMidi : NSObject
{
	PGMidi				*midi;
	const Byte			*message;
	
	TSASynthController	*synth;
	TSACoreGraph		*graph;
	TSACoreFeedback		*echo;
	
	LNCStopwatch		*tickTimer;
	double				avgTickElapsed;
	float				bpm;
}

@property (nonatomic, assign) PGMidi *midi;
@property (nonatomic, assign) TSASynthController *synth;
@property (nonatomic, assign) TSACoreGraph *graph;

- (void) controller:(int)number value:(int)value;

@end
