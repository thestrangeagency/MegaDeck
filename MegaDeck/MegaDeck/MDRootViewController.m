//
//  MDRootViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/19/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDRootViewController.h"

@interface MDRootViewController ( Private )

- (void)showChildView:(UIViewController*)viewController;
- (void)hideChildView;

@end

@implementation MDRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setupMenubar
{
	UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] 
									 initWithTitle:@"Source" 
									 style:UIBarButtonItemStyleBordered
									 target:self 
									 action:@selector(handleSourceBarItem:)];
	
	UIBarButtonItem *sessionButton = [[UIBarButtonItem alloc] 
									  initWithTitle:@"Session" 
									  style:UIBarButtonItemStyleBordered 
									  target:self 
									  action:@selector(handleSessionBarItem:)];
	
	NSArray *items = [NSArray arrayWithObjects:sourceButton, sessionButton, nil];
	
	menuBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[menuBar setItems:items];
	[menuBar setBarStyle:UIBarStyleBlackTranslucent];
	[self.view addSubview:menuBar];
	
	[sourceButton release];
	[sessionButton release];
}

// ----------------------------------------------------------------------- View lifecycle
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSLog(@"loaded root with size %f, %f", self.view.frame.size.width, self.view.frame.size.height);
	
	[self setupMenubar];
	[self handleSourceBarItem:nil];
}

- (void)viewDidUnload
{
	[menuBar release];
	menuBar = nil;
	[childViewController release];
	childViewController = nil;
	
    [super viewDidUnload];
}

- (void)dealloc 
{
	[menuBar release];	
	[super dealloc];
}

// ----------------------------------------------------------------------- MDSoundViewControllerDelegate
#pragma mark MDSoundViewControllerDelegate

- (void) soundViewController:(MDSoundViewController*)viewController didEdit:(MDSoundModel*)soundModel
{
	[self hideChildView];
}

// ----------------------------------------------------------------------- Child view control
#pragma mark child view control

- (void)showChildView:(UIViewController*)viewController;
{
	childViewController = viewController;
	[self.view addSubview:childViewController.view];
	
	if( [childViewController respondsToSelector:@selector(setDelegate:)] )
		[childViewController performSelector:@selector(setDelegate:) withObject:self];
}

- (void)hideChildView
{
	[childViewController.view removeFromSuperview];
	[childViewController release];
	childViewController = nil;
}

// ----------------------------------------------------------------------- MenuBar handlers
#pragma mark menuBar

- (void)handleSourceBarItem:(id)sender 
{
	[self showChildView:[[MDSoundViewController alloc] 
						 initWithModel:[[MDAppDelegate sharedAppDelegate] sourceModel]
						 player:[[MDAppDelegate sharedAppDelegate] sourcePlayer]]];
}

- (void)handleSessionBarItem:(id)sender
{
}

@end