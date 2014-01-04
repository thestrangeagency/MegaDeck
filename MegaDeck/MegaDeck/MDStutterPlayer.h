//
//  MDStutterPlayer.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/30/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDSoundPlayer.h"
#import "TPCircularBuffer.h"

typedef struct
{
	TPCircularBuffer *buffer;
	SInt64		*start;
	UInt32		*length;
	UInt32		position;
	BOOL		*isReady;
	BOOL		isPlaying;
} StutterStruct;

@interface MDStutterPlayer : MDSoundPlayer
{
	StutterStruct *stutter;
	NSTimer *ticToc;
	BOOL first;
}

@end
