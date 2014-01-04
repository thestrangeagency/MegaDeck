//
//  GrainMidi.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/19/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDMidi.h"
#import "LNCStopwatch.h"

#define MIDI_MODWHEEL	@"MIDI_MODWHEEL"

@interface GrainMidi : MDMidi
{
	LNCStopwatch *modTimer;
	float lastModTime;
	float allowance;
}
@end
