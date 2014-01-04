//
//  MegaSliceAppDelegate.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MegaLayerAppDelegate.h"

@implementation MegaLayerAppDelegate

- (void) installPresetSounds
{
	BOOL hasInstalledDefaultLoops = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasInstalledSounds"];
	
	if( !hasInstalledDefaultLoops)
	{
		NSLog(@"Installing default sounds");
		
		NSArray *iniLoopNames = [NSArray arrayWithObjects:
								 @"Bassline",
								 @"Main Beat",
								 @"Percussion",
                                 @"Hi Hats",
                                 @"Chorus Synth",
								 @"Verse Synth",
                                 @"Destroyer",
                                 @"TOM 4",
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
				[[NSUserDefaults standardUserDefaults] setObject:filePath 
														  forKey:[NSString stringWithFormat:@"LOOP_%i",i]];
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
	
	sliceController = [[SliceController alloc] initWithVoiceCount:LAYERS];
	[sliceController attachToGraph:coreGraph];
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
								 @"YES",							@"use_wave_view",
								 [NSNumber numberWithFloat:4.f],	@"bars_per_loop",
								 nil];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	
#if TARGET_NAME == MegaLayer
	[[MDTransportModel sharedMDTransportModel] setBpm:130.f];
#endif
	
}

/**
 * override since this synth controller persists
 */
- (void) showSynth
{
	if( !layerViewController)
	{
		layerViewController = [[LayerViewController alloc] initWithNibName:@"MDSynthViewController" bundle:[NSBundle mainBundle]];
		[layerViewController setSliceController:sliceController];
	}
	[self showChildView:layerViewController];
	[layerViewController refresh];
}

/**
 * override to keep slice view around
 */
- (void) hideChildView
{
	[childViewController.view removeFromSuperview];
	if( childViewController != layerViewController )
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
