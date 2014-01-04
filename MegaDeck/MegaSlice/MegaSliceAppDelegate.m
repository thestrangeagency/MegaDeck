//
//  MegaSliceAppDelegate.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MegaSliceAppDelegate.h"

@implementation MegaSliceAppDelegate

- (void) installPresetSounds
{
	BOOL hasInstalledDefaultLoops = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasInstalledSounds"];
	
	if( !hasInstalledDefaultLoops)
	{
		NSLog(@"Installing default sounds");
		
		NSArray *iniLoopNames = [NSArray arrayWithObjects:
                                 @"Factory A",
                                 @"Factory B",
								 @"Factory C",
								 @"Factory D",
                                 @"Factory E",
                                 @"Factory F",
                                 @"Factory G",
                                 @"Factory H",
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
			
			@try 
			{
				[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:loopName ofType:@"mp3"] 
									 toPath:filePath
									  error:&error];
				if( i < 2 )
					[[NSUserDefaults standardUserDefaults] setObject:filePath forKey:[NSString stringWithFormat:@"LOOP_%i",i]];
			}
			@catch (NSException *exception) 
			{
				NSLog(@"ERROR default file missing");
			}
			
			i++;
		}

		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasInstalledSounds"];
			
		[docPath release];
	}
}

- (void) initSynth
{
	// First run only, install presets
	[self installPresetSounds];
	
	sliceController = [[SliceController alloc] initWithVoiceCount:2];
	[sliceController attachToGraph:coreGraph];
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"YES",							@"use_wave_view",
								 [NSNumber numberWithFloat:4.f],	@"bars_per_loop",
								 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
}

/**
 * override since this synth controller persists
 */
- (void) showSynth
{
	if( !sliceViewController)
	{
		sliceViewController = [[SliceViewController alloc] initWithNibName:@"MDSynthViewController" bundle:[NSBundle mainBundle]];
		[sliceViewController setSliceController:sliceController];
	}
	[self showChildView:sliceViewController];
	[sliceViewController refresh];
}

/**
 * override to keep slice view around
 */
- (void) hideChildView
{
	[childViewController.view removeFromSuperview];
	if( childViewController != sliceViewController )
	{
		[childViewController release];
		childViewController = nil;
	}
}

- (void) editSourceModel:(MDSoundModel*)model
{
	[self showChildView:[[MDSoundViewController alloc]
						 initWithModel:model
						 player:soundPlayer]];
}

@end
