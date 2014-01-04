//
//  StokeChannel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeChannel.h"

static int i = 0;

@implementation StokeChannel

@synthesize soundModel, loop;

- (id)init 
{
    self = [super init];
    if (self) 
	{
        soundModel = [[MDSoundModel alloc] init];
		
		[soundModel setThroughOk:NO];
		[soundModel setLastFileKey:[NSString stringWithFormat:@"C_%i",i]];
		[soundModel setRecordPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"C_%i.WAV",i]]];
		i++;
		
		[soundModel readLastAudioFile];
		
		loop = [[StokeLoop alloc] init];
    }
    return self;
}

- (void)dealloc 
{
    [soundModel release];
    [super dealloc];
}

// ---------------------------------------------------------------------------------------------------- NSCoding
#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) 
	{
		soundModel = [[decoder decodeObjectForKey:@"sound"] retain];
		loop = [[decoder decodeObjectForKey:@"loop"] retain];
		
		[soundModel readLastAudioFile];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:soundModel forKey:@"sound"];
    [encoder encodeObject:loop forKey:@"loop"];
}

// ---------------------------------------------------------------------------------------------------- loop control
#pragma mark - loop control

/**
 NOTE: A channel can have more than one loop, so we're routing through here.
 Other loop params may move here too if channels get extended with multiple loops.
 */

- (float) level
{
	return loop.level;
}

- (void) setLevel:(float)level
{
	loop.level = level;
}

- (void) clear
{
	[loop clear];
}

@end
