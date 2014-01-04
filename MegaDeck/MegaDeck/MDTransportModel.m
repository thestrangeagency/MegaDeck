//
//  MDTransportModel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/12/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDTransportModel.h"
#import "SynthesizeSingleton.h"

@implementation MDTransportModel

SYNTHESIZE_SINGLETON_FOR_CLASS(MDTransportModel);

- (id)init 
{
    self = [super init];
    if (self) 
	{
		model.bpm = 120;
		model.isPlaying = YES;
    }
    return self;
}

- (TransportModel*)model
{
	return &model;
}

- (void) setIsPlaying:(BOOL)shouldPlay
{
	model.isPlaying = shouldPlay;
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_TRANSPORT_NOTIFICATION object:self];
}

- (void) play
{
	[self setIsPlaying:YES];
}

- (void) stop
{
	[self setIsPlaying:NO];
}

- (void) setBpm:(float)bpm
{
	model.bpm = bpm;
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_TRANSPORT_NOTIFICATION object:self];
}

- (float) bpm
{
	return model.bpm;
}

@end
