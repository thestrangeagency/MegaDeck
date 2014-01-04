//
//  MDRootViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/19/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDSoundViewController.h"
#import "MDSoundModel.h"
#import "MDAppDelegate.h"

@interface MDRootViewController : UIViewController <MDSoundViewControllerDelegate>
{
	UIToolbar *menuBar;	
	UIViewController *childViewController;
}

- (void)handleSourceBarItem:(id)sender;
- (void)handleSessionBarItem:(id)sender;

@end
