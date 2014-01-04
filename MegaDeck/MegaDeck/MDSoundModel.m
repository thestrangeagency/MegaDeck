//
//  MDSourceModel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/20/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDSoundModel.h"

@implementation MDSoundModel

@synthesize audioBuffer, lastPath, defaultPath, start, length, lastFileKey, isReady, readOnly, recordPath, throughOk;

- (id)init 
{
    self = [super init];
    if (self) 
	{
        isReady = NO;
		[self clear];
		
		audioBuffer = (AudioBuffer*)calloc(1, sizeof(AudioBuffer));
		lastFileKey = LAST_FILE_PATH;
		defaultPath = [[[NSBundle mainBundle] pathForResource:@"default" ofType:@"mp3"] retain];
		lastPath = nil;
		throughOk = YES;
    }
    return self;
}

- (void) dealloc
{
	[audioFile release];
	[super dealloc];
}

// ---------------------------------------------------------------------------------------------------- NSCoding
#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) 
	{
		isReady = NO;
		[self clear];
		
		audioBuffer = (AudioBuffer*)calloc(1, sizeof(AudioBuffer));
		defaultPath = [[[NSBundle mainBundle] pathForResource:@"default" ofType:@"mp3"] retain];

		lastPath = [[decoder decodeObjectForKey:@"path"] retain];
		throughOk = [decoder decodeBoolForKey:@"thru"];
		lastFileKey = [[decoder decodeObjectForKey:@"last_key"] retain];
		recordPath = [[decoder decodeObjectForKey:@"record_path"] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:lastPath forKey:@"path"];
	[encoder encodeBool:throughOk forKey:@"thru"];
	[encoder encodeObject:lastFileKey forKey:@"last_key"];
	[encoder encodeObject:recordPath forKey:@"record_path"];
}

// ----------------------------------------------------------------------- file i/o
#pragma mark - file i/o

- (void) readLastAudioFile
{
	if( lastFileKey )
		lastPath = [[NSUserDefaults standardUserDefaults] stringForKey:lastFileKey];
	
	// if no last path or file gone, use a default
	if( !lastPath || ![[NSFileManager defaultManager] fileExistsAtPath:lastPath] )
		lastPath = [self defaultPath];
	
	[self readAudioFileAtPath:lastPath];
}

- (void) readAudioFileAtPath:(NSString*)path
{
	NSLog(@"MDSoundModel reading path: %@", path);
	
	NSAssert(path != nil, @"MDSoundModel attempt to load NULL path or default path missing!");
	
	// notify listeners of new audio file
	[[NSNotificationCenter defaultCenter] postNotificationName:FILE_LOADING object:self];
	
	if( !audioFile )
	{
		audioFile = [[TSAAudioFileIO alloc] init];
		[audioFile setDelegate:self];
	}
	
	[self clear];
	
	[audioFile readFileAtPath:path intoBuffer:audioBuffer];
}

- (void) audioFileDidFinishReading:(TSAAudioFileIO*)file
{	
	start = 0;
	length = frameCount = [file frameCount];
	isReady = YES;
	
	lastPath = [file filePath];
	
	NSLog(@" p:%@", lastPath);
	NSLog(@" k:%@", lastFileKey);
	
	if( lastFileKey )
		[[NSUserDefaults standardUserDefaults] setObject:lastPath forKey:lastFileKey];
	
	// notify listeners of new audio file
	[[NSNotificationCenter defaultCenter] postNotificationName:FILE_LOADED object:self];
}

-(void) audioFileDidFail:(TSAAudioFileIO*)file
{
	NSLog(@"Failed to load audio file, loading default");
	[self readAudioFileAtPath:[self defaultPath]];
}

- (void) saveBufferToPath:(NSString*)path
{
	if( !isReady ) return;
	
	if( !audioFile )
	{
		audioFile = [[TSAAudioFileIO alloc] init];
		[audioFile setDelegate:self];
	}
	[audioFile setDefaultFileFormat];
	[audioFile saveBuffer:audioBuffer toFilePath:path frames:length fromOffset:start];
}

- (void) clear
{
	isReady = NO;
	start = length = frameCount = 0;
}

// ----------------------------------------------------------------------- manual non file
#pragma mark - manual non file

- (void) setBufferData:(UInt32*)data withLength:(UInt32)frames format:(AudioStreamBasicDescription)format
{
	audioBuffer->mData = data;
	audioBuffer->mNumberChannels = format.mChannelsPerFrame;
	audioBuffer->mDataByteSize = format.mBytesPerFrame;

	start = 0;
	length = frameCount = frames;
	isReady = YES;
	
	// notify listeners of new audio file
	[[NSNotificationCenter defaultCenter] postNotificationName:FILE_LOADED object:self];
}

// ----------------------------------------------------------------------- pointer access
#pragma mark - pointer access

- (NSData*) getBufferData
{
	return [NSData dataWithBytes:audioBuffer->mData length:audioBuffer->mDataByteSize];
}

- (BOOL*) isReadyPtr
{
	return &isReady;
}

- (SInt64*) startPtr
{
	return &start;
}

- (UInt32*) lengthPtr
{
	return &length;
}

// ----------------------------------------------------------------------- raw size
#pragma mark - raw size

- (UInt32) frameCount
{
	AssertWithStackSymbols(isReady);
	return frameCount;
}

// ----------------------------------------------------------------------- float converters
#pragma mark - float converters

- (void) setStartFraction:(float)fraction
{
	start = fraction * [self frameCount];
}

- (float) startFraction;
{
	return (float)start / [self frameCount];
}

- (void) setEndFraction:(float)fraction
{
	length = fraction * [self frameCount] - start;
}

- (float) endFraction
{
	return (float)(start+length) / [self frameCount];
}

- (void) setLengthFraction:(float)fraction
{
	length = fraction * [self frameCount];
}

- (float) lengthFraction
{
	return (float)length / [self frameCount];
}

- (UInt32) frameWithSelectionFraction:(float)fraction
{
	return start + (length * fraction );
}

- (float) fractionWithSelectionFraction:(float)fraction
{
	return [self startFraction] + ([self lengthFraction] * fraction );
}

// ----------------------------------------------------------------------- string coverters
#pragma mark - string converters

- (NSString*) sampleFloatToString:(float)samples
{
	float seconds = samples / 44100;
	int minutes = seconds / 60;
	seconds = fmodf(seconds, 60);
	return [NSString stringWithFormat:@"%02i:%05.2f", minutes, seconds];
}

- (NSString*) startString
{
	return [self sampleFloatToString:start];
}

- (NSString*) endString
{
	return [self sampleFloatToString:start+length];
}

- (NSString*) lengthString
{
	return [self sampleFloatToString:length];
}

@end
