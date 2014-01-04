//
//  MDCircularSoundModel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/30/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDCircularSoundModel.h"

#define kFrames		44100*4*4	// 4 seconds

@implementation MDCircularSoundModel

- (TPCircularBuffer*) bufferPtr
{
	return &buffer;
}

- (id)init 
{
    self = [super init];
    if (self) 
	{
		NSLog(@"initializing circle");
		TPCircularBufferInit(&buffer, kFrames);
		audioBuffer->mData = NULL;
    }
    return self;
}

- (void) dealloc
{
	TPCircularBufferCleanup(&buffer);
	[super dealloc];
}

- (void) readAudioFileAtPath:(NSString*)path
{
	NSLog(@"circle model readAudioFileAtPath %@",path);
	
	offset = 0;
	length = 0;
	
	// notify listeners of new audio file
	[[NSNotificationCenter defaultCenter] postNotificationName:FILE_LOADING object:self];
	
	if( !audioFile )
	{
		audioFile = [[TSAAudioFileIO alloc] init];
		[audioFile setDelegate:self];
	}
	isReady = NO;
	[audioFile readFileAtPath:path intoBuffer:audioBuffer frames:kFrames fromOffset:offset];
}

-(void) audioFile:(TSAAudioFileIO*)file didReadFrames:(UInt32*)frames
{
	int produced = TPCircularBufferProduceBytes(&buffer, audioBuffer->mData, *frames * file.clientFormat.mBytesPerFrame);
	offset += produced / file.clientFormat.mBytesPerFrame;
	// override file's offset, to reflect how much data was actually pushed into the buffer
	[file setTransferOffset:offset];
}

@end