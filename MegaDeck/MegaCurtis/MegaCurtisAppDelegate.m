//
//  MDCAppDelegate.m
//  MegaCurtis
//
//  Created by Lucas Kuzma on 2/17/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MegaCurtisAppDelegate.h"
#import "GrainSynthController.h"
#import "GrainSynthViewController.h"
#import "GrainMidi.h"

@implementation MegaCurtisAppDelegate

- (void) installPresetSounds
{
	BOOL hasInstalledDefaultLoops = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasInstalledSounds"];
	
	if( !hasInstalledDefaultLoops )
	{
		NSLog(@"Installing default sounds");
		
		NSArray *iniLoopNames = [NSArray arrayWithObjects:
								 @"Strange Belief",
								 @"Strange Mission",
								 @"Strange Song",
								 @"Strange Zoo",
								 nil];
		
		NSString *root;
		NSURL *docPath;
		
		root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
		docPath = [[NSURL fileURLWithPath:root isDirectory:YES] retain];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		
		for(NSString *loopName in iniLoopNames)
		{
			[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:loopName ofType:@"mp3"] 
								 toPath:[[docPath path] stringByAppendingPathComponent:loopName] 
								  error:&error];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasInstalledSounds"];
		
		[docPath release];
	}
}

- (void) initSynth
{
	synth = [[GrainSynthController alloc] initWithVoiceCount:4];
	[synth setDelegate:self];
	[synth attachToGraph:coreGraph];
	[(GrainSynthController*)synth setSoundModel:sourceModel];
	
	if (launchUrl != nil && [launchUrl isFileURL]) 
	{
		NSLog(@"open launchUrl: %@", [launchUrl absoluteString]);
		[sourceModel readAudioFileAtPath:[launchUrl path]];
		launchUrl = nil;
    }
	else
	{
		[sourceModel readLastAudioFile];
	}
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [self isPaid] ? 
		[NSDictionary dictionaryWithObjectsAndKeys:
		 @"NO",		@"use_wave_view",
		 @"NO",		@"portrait_x_pitch",
		 nil]
		:
		[NSDictionary dictionaryWithObjectsAndKeys:
		 @"YES",	@"use_wave_view",
		 @"YES",	@"portrait_x_pitch",
		 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
	// First run only, install presets
	[self installPresetSounds];
}

- (void) initRecorders
{
	inputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:input onGraph:coreGraph];
	outputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:output onGraph:coreGraph];
	
	[inputRecorder preparePlaythroughWithSize:MAX_GRAIN_SIZE];
}

- (void) initMidi
{
	if( [self isPaid] )
		midi = [[GrainMidi alloc] init];
}

- (void) showSynth
{
	[self showChildView:[[GrainSynthViewController alloc] initWithNibName:@"MDSynthViewController" bundle:[NSBundle mainBundle]]];
}

- (BOOL) isPaid
{
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSLog(@"bundleIdentifier %@", bundleIdentifier);
	
	if( [bundleIdentifier isEqualToString:@"com.thestrangeagency.MegaCurtis"] )
		return YES;
	else
		return NO;
}

// ---------------------------------------------------------------------------------------------------- 
#pragma mark -

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if (url != nil && [url isFileURL]) 
	{
		NSLog(@"open launchUrl: %@", [url absoluteString]);
		[sourceModel readAudioFileAtPath:[url path]];
    }
    return YES;
}

// ---------------------------------------------------------------------------------------------------- SynthControllerDelegate
#pragma mark - SynthControllerDelegate

- (BOOL) isPlaythrough
{
	return [inputRecorder isPlaythrough];
}

- (UInt32*) offsetPtr
{
	return &inputRecorder.context->throughOffset;
}

@end