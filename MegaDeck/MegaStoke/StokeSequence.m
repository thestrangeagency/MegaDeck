//
//  StokeSequence.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeSequence.h"

@implementation StokeSequence

- (id) initWithVoiceCount:(int)nVoices
{
	self = [super init];
    if (self) 
	{
		channels = [[NSMutableArray alloc] initWithCapacity:nVoices];
		for (int i=0; i<nVoices; i++)
		{
			StokeChannel *channel = [[StokeChannel alloc] init];
			[channels addObject:channel];
			[channel release];
		}		
    }
    return self;
}

- (void) dealloc
{
	[channels removeAllObjects];
    [channels release];
    [super dealloc];
}

- (int) voiceCount
{
	return [channels count];
}

- (StokeChannel*) channelAtIndex:(int)index;
{
	return [channels objectAtIndex:index];
}

- (void) clear
{
	for (StokeChannel *channel in channels)
	{
		[channel clear];
	}
}

- (void) serialize
{
	NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	NSURL *docPath = [[NSURL fileURLWithPath:root isDirectory:YES] retain];
	NSString *filePath = [[[docPath path] stringByAppendingPathComponent:@"Sequences"] stringByAppendingPathComponent:@"x.plist"];
	
	NSError *error = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:[[docPath path] stringByAppendingPathComponent:@"Sequences"] 
							  withIntermediateDirectories:NO 
											   attributes:nil 
													error:&error];
	
	BOOL success = [NSKeyedArchiver archiveRootObject:channels toFile:filePath];
	NSLog(@"archived %i",success);
	
	/*
	NSString *error = nil;
	NSData *mySerializedObject = [NSKeyedArchiver archivedDataWithRootObject:channels];
	NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:mySerializedObject
																 format:NSPropertyListXMLFormat_v1_0
													   errorDescription:&error];
	if( xmlData ) {
		[xmlData writeToFile:filePath atomically:YES];
	} else {
		NSLog(@"%@",error);
		[error release];
	}
	 */
}

- (void) unserialize
{
	NSLog(@"unarchiving");
	
	NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	NSURL *docPath = [[NSURL fileURLWithPath:root isDirectory:YES] retain];
	NSString *filePath = [[[docPath path] stringByAppendingPathComponent:@"Sequences"] stringByAppendingPathComponent:@"x.plist"];

	[self clear];
	[channels release];
	channels = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
}

@end
