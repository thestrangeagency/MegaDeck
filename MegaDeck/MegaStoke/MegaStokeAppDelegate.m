//
//  MegaStokeAppDelegate.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MegaStokeAppDelegate.h"
#import "GrainMidi.h"
#import "StokeViewController.h"

@implementation MegaStokeAppDelegate

@synthesize stokeController;

- (void) selectChannel:(int)channel
{
	synth = [stokeController synthForChannel:channel];
	[stokeViewController refreshPanel];
}

- (void) installPresetSounds
{
	BOOL hasInstalledDefaultLoops = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasInstalledSounds"];
	
	if( !hasInstalledDefaultLoops )
	{
		NSLog(@"Installing default sounds");
		
		NSArray *iniLoopNames = [NSArray arrayWithObjects:
								 @"stoke_0",
								 @"stoke_1",
								 @"stoke_2",
								 @"stoke_3",
								 nil];
		
		NSString *root;
		NSURL *docPath;
		
		root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
		docPath = [[NSURL fileURLWithPath:root isDirectory:YES] retain];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		int i=0;
		
		for(NSString *loopName in iniLoopNames)
		{
			NSString *filePath = [[docPath path] stringByAppendingPathComponent:loopName];
			[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:loopName ofType:@"mp3"] 
								 toPath:filePath
								  error:&error];
			[[NSUserDefaults standardUserDefaults] setObject:filePath forKey:[NSString stringWithFormat:@"C_%i",i]];
			i++;
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasInstalledSounds"];
		
		[docPath release];
	}
}

- (void) initSynth
{
	[self installPresetSounds];
	
	stokeController = [[StokeController alloc] initWithVoiceCount:N_VOICES];
	[stokeController attachToGraph:coreGraph];
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"YES",	@"shake_for_help",
								 @"YES",	@"use_wave_view",
								 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
}

- (void) initRecorders
{
	inputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:input onGraph:coreGraph];
	outputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:output onGraph:coreGraph];
	
	//[inputRecorder preparePlaythroughWithSize:MAX_GRAIN_SIZE];
}

- (void) initMidi
{
	//if( [self isPaid] )
		//midi = [[GrainMidi alloc] init];
	
	// stokeSequencer = [[StokeSequencer alloc] initWithController:stokeController];
}

/**
 * override since this synth controller persists
 */
- (void) showSynth
{
	if( !stokeViewController )
		stokeViewController = [[StokeViewController alloc] initWithNibName:@"MDSynthViewController" bundle:[NSBundle mainBundle]];
	[self showChildView:stokeViewController];
	[stokeViewController refresh];
}

/**
 * override to keep space view around, since this app can has an external screen
 */
- (void) hideChildView
{
	[childViewController.view removeFromSuperview];
	if( childViewController != stokeViewController )
	{
		[childViewController release];
		childViewController = nil;
	}
}

- (BOOL) isPaid
{
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSLog(@"bundleIdentifier %@", bundleIdentifier);
	
	if( [bundleIdentifier isEqualToString:@"com.thestrangeagency.MegaStoke"] )
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

- (void) editSourceModel:(MDSoundModel*)model
{
	[self showChildView:[[MDSoundViewController alloc]
						 initWithModel:model
						 player:soundPlayer]];
}

@end
