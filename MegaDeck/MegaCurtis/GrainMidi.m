//
//  GrainMidi.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/19/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainMidi.h"
#import "TSACoreGraph+Control.h"
#import "NSNotificationAdditions.h"

#define MOD_RATE_LIMIT	16.f // per second

@implementation GrainMidi

- (id) init
{
	self = [super init];
    if (self)
	{
		modTimer = [[LNCStopwatch alloc] init];
		[modTimer start];
		allowance = MOD_RATE_LIMIT;
	}
	return self;
}

- (void)dealloc 
{
    [modTimer stop];
	[modTimer release];
    [super dealloc];
}

/**
 * NOTE: this runs on the MIDI thread, may need to post to main thread
 */
- (void) controller:(int)number value:(int)value
{
	[super controller:number value:value];
	
	float floatValue = value/127.f;
		
	// modwheel
	if( number == 1 )
	{
		// rate limit	
		float now = [modTimer elapsedSeconds];
		float elapsed = now - lastModTime;
		lastModTime = now;
		
		allowance += elapsed * MOD_RATE_LIMIT;
		if( allowance > MOD_RATE_LIMIT )
			allowance = MOD_RATE_LIMIT;
		if( allowance >= 1.f )
		{
			allowance -= 1.f;
			
			NSNumber *floatNumber = [[NSNumber alloc] initWithFloat:floatValue];
			NSDictionary *userDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:floatNumber,@"value",nil];
			[floatNumber release];
			
			[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:MIDI_MODWHEEL 
																				object:self 
																			  userInfo:userDictionary];
			[userDictionary release];
		}
	}

}

@end
