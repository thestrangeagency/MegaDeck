//
//  MDCircularSoundModel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/30/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDSoundModel.h"
#import "TPCircularBuffer.h"

@interface MDCircularSoundModel : MDSoundModel
{
	TPCircularBuffer buffer;
	SInt64 offset;
}

@property (readonly) TPCircularBuffer *bufferPtr;

@end
