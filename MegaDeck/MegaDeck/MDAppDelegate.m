//
//  MDAppDelegate.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/19/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDSynthViewController.h"
#import "TSACoreGraph+Mixer.h"
#import "MDKeyModel.h"

@interface MDAppDelegate ( /* private */ )

// - (void) showChildView:(UIViewController*)viewController;
- (void) hideChildView;

@end

@implementation MDAppDelegate

@synthesize window = _window;
@synthesize sourceModel, sessionModel, soundPlayer, inputRecorder, outputRecorder, synth, echo;
@synthesize graph = coreGraph;

- (void) initSynth
{
	synth = [[TSASynthController alloc] initWithVoiceCount:4];
	[synth attachToGraph:coreGraph];
}

- (void) initRecorders
{
	inputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:input onGraph:coreGraph];
	outputRecorder = [[TSACoreGraphRecorder alloc] initWithMode:output onGraph:coreGraph];
}

- (void) initMidi
{
	midi = [[MDMidi alloc] init];
}

- (void) initSound
{
	session = [[TSASessionController alloc] init];
	[session forceSpeaker:YES];
	
	coreGraph = [[TSACoreGraph alloc] init];
	[coreGraph connectGraph];
		
	soundPlayer = [[MDSoundPlayer alloc] init];
	[coreGraph addMixerBusCallback:[soundPlayer renderCallback]];
	
	sourceModel = [[MDSoundModel alloc] init];
	[sourceModel setLastFileKey:@"LAST_SOURCE"];
	
	[self initSynth];
	[self initRecorders];
	
	sessionModel = [[MDSoundModel alloc] init];
	[sessionModel setLastFileKey:nil];	
	[sessionModel setReadOnly:YES];
	[sessionModel setDefaultPath:[outputRecorder defaultRecordPath]];

	echo = [[TSACoreFeedback alloc] init];
	[echo feed:[coreGraph mConverter] intoGraph:coreGraph];
	[echo setDelayLength:11025];
	
	[coreGraph initGraph];
	[coreGraph startAUGraph];
	
	[self initMidi];
}

- (void)dealloc
{
	[sourceModel release];
	[soundPlayer release];

	[_window release];
    [super dealloc];
}

- (BOOL) isPaid
{
	return YES;
}

// ----------------------------------------------------------------------- child view control
#pragma mark child view control

- (void) showChildView:(UIViewController*)viewController
{
	if( childViewController ) 
		[self hideChildView];
	
	childViewController = viewController;
	[self.window addSubview:childViewController.view];
	
	if( [childViewController respondsToSelector:@selector(setDelegate:)] )
		[childViewController performSelector:@selector(setDelegate:) withObject:self];
	
	// iOS 6
	[self.window setRootViewController:childViewController];
}

- (void) hideChildView
{
	[childViewController.view removeFromSuperview];
	[childViewController release];
	childViewController = nil;
}

- (void) editSource
{
	[self showChildView:[[MDSoundViewController alloc]
						 initWithModel:sourceModel
						 player:soundPlayer]];
}

- (void) editSession
{
	[self showChildView:[[MDSoundViewController alloc]
						 initWithModel:sessionModel
						 player:soundPlayer]];
}

- (void) showSynth
{
	[self showChildView:[[MDSynthViewController alloc] init]];
}

// ----------------------------------------------------------------------- MDSoundViewControllerDelegate
#pragma mark MDSoundViewControllerDelegate

- (void) soundViewController:(MDSoundViewController*)viewController didEdit:(MDSoundModel*)soundModel
{
	[self showSynth];
}

// ----------------------------------------------------------------------- application state
#pragma mark application state

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
	
	launchUrl = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
	
	[self initSound];
	[self showSynth];
	
    [self.window makeKeyAndVisible];
	
	// init functions above can set launchUrl to nil to skip this
	if (launchUrl)
	{
        return [self application:application openURL:launchUrl sourceApplication:nil annotation:nil];
	}
	
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	NSLog(@"applicationDidEnterBackground");
	[[MDKeyModel sharedMDKeyModel] serialize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
	NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

/**
 * no need to cast each time singleton is accessed
 */
+ (MDAppDelegate*) sharedAppDelegate
{
    return (MDAppDelegate*)[[UIApplication sharedApplication] delegate];
}

@end
