//
//  MDSoundModel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/20/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//
//  Wrapper for audio buffer with file i/o methods
//

#import <Foundation/Foundation.h>
#import "TSAAudioFileIO.h"

#define LAST_FILE_PATH	@"MD_MODEL_LAST_PATH"
#define FILE_LOADED		@"FILE_LOADED"
#define FILE_LOADING	@"FILE_LOADING"

@interface MDSoundModel : NSObject <TSAAudioFileIODelegate, NSCoding>
{
	TSAAudioFileIO	*audioFile;
	AudioBuffer		*audioBuffer;
	
	BOOL			isReady;
	BOOL			readOnly;
	BOOL			throughOk;
	
	NSString		*defaultPath;
	NSString		*lastPath;
	NSString		*lastFileKey;
	NSString		*recordPath;

	UInt32			frameCount;
	
	// trim
	SInt64			start;
	UInt32			length;
}

@property					AudioBuffer		*audioBuffer;
@property (copy, readonly)	NSString		*lastPath;
@property					SInt64			start;
@property					UInt32			length;
@property (readonly)		UInt32			frameCount;
@property					BOOL			isReady;
@property					BOOL			readOnly;
@property					BOOL			throughOk;

// override key for last file in user prefs or nil to not store last file
@property (copy) NSString	*lastFileKey;

// override default file path
@property (copy) NSString	*defaultPath;

// override record file path
@property (copy) NSString	*recordPath;

// pointer access for high-speed routines
@property (readonly) BOOL	*isReadyPtr;
@property (readonly) SInt64 *startPtr;
@property (readonly) UInt32	*lengthPtr;

// sample window as a fraction of the audio data
@property float	startFraction;
@property float	endFraction;
@property float	lengthFraction;

// string methods
@property (readonly, copy) NSString	*startString;
@property (readonly, copy) NSString	*endString;
@property (readonly, copy) NSString	*lengthString;

- (void) readLastAudioFile;
- (void) readAudioFileAtPath:(NSString*)path;
- (void) saveBufferToPath:(NSString*)path;
- (void) clear;

// absolute position from fraction of selected region
- (UInt32) frameWithSelectionFraction:(float)fraction;
- (float) fractionWithSelectionFraction:(float)fraction;

// raw buffer access
- (void) setBufferData:(UInt32*)data withLength:(UInt32)frames format:(AudioStreamBasicDescription)format;
- (NSData*) getBufferData;

@end
