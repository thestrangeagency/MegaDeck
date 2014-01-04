//
//  MDSoundPlayer.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/29/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//
//  Provides a rendering callback for an MDSoundModel

#import <Foundation/Foundation.h>
#import "MDSoundModel.h"

typedef struct
{
	AudioBuffer	*audioBuffer;
	SInt64		*start;
	UInt32		*length;
	UInt32		position;
	BOOL		*isReady;
	BOOL		isPlaying;
} PlaybackStruct;

@interface MDSoundPlayer : NSObject
{
	AURenderCallbackStruct renderCallback;
	MDSoundModel *soundModel;
	PlaybackStruct *sound;
}

@property (readonly) AURenderCallbackStruct renderCallback;
@property (retain, nonatomic) MDSoundModel *soundModel;
@property BOOL isPlaying;

/**
 * Optional convenience initializer
 */
- (id)initWithModel:(MDSoundModel*)model;

- (void) play;
- (void) stop;

- (float) positionFraction;

@end
