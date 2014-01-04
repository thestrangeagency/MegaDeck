//
//  MCSoundViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MCSoundViewController.h"

@implementation MCSoundViewController

/**
 * override super to hide name and labels
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	[nameLabel removeFromSuperview];
}

/**
 * override super to force wave view
 */
- (void) soundDidLoad
{
	[super soundDidLoad];
	[waveTrimView setShouldUseWaveView:YES];
	[self updateTrimLabels];
}

/**
 * override super to keep labels in one spot
 */
- (void) updateTrimLabels____NOT
{
	[startLabel setText:[soundModel startString]];
	[endLabel setText:[soundModel endString]];	
}

/**
 * override super to only show labels when trimming
 */
- (void) updateTrimLabels
{
	CGRect labelFrame = startLabel.frame;
	CGRect trimFrame = CGRectMake(WAVE_TRIM_RECT);
	CGFloat trimTop = trimFrame.origin.y;
	CGFloat trimHeight = trimFrame.size.height;
	CGFloat labelHeight = labelFrame.size.height;
	CGFloat	border = 8;
	
	labelFrame.origin.y = trimTop + MIN( trimHeight - (border + 2*labelHeight), MAX(border, trimHeight * [waveTrimView startFraction] - border) );
	[startLabel setHidden: labelFrame.origin.y > trimTop + border ? NO : YES];
	[startLabel setFrame:labelFrame];
	[startLabel setText:[soundModel startString]];
	
	labelFrame.origin.y = trimTop + trimHeight * [waveTrimView endFraction];
	[endLabel setHidden: labelFrame.origin.y < trimTop + trimHeight - (border + labelHeight) ? NO : YES];
	[endLabel setFrame:labelFrame];
	[endLabel setText:[soundModel endString]];	
}

/**
 * override super to dynamically update other wave view
 */
- (void) waveViewDidChange
{
	[super waveViewDidChange];
	[delegate soundViewController:self didEdit:soundModel];
}

/**
 * override super to use popover docs view
 */
- (void)showDocsViewWithMode:(int)browserMode
{
	TSADocumentsViewController *docsView = [[TSADocumentsViewController alloc] initWithMode:browserMode];
	[docsView setDelegate:self];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:docsView];
	navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[docsView release];
	
	[popover release];
	popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	popover.popoverContentSize = CGSizeMake(360, 480);
	[popover presentPopoverFromRect:CGRectMake(720, 40, 40, 40) 
							 inView:self.view.superview 
		   permittedArrowDirections:UIPopoverArrowDirectionAny 
						   animated:YES];
	[navigationController release];
}

- (void)hideIoView
{
	[popover dismissPopoverAnimated:YES];
	[popover release];
    popover = nil;
}

/**
 * override super to use popover style action sheet
 */
- (IBAction) action
{
	if( ![soundModel readOnly] )
		actionsSheet = [[UIActionSheet alloc] 
						initWithTitle:@"Action" 
						delegate:self 
						cancelButtonTitle:@"Cancel" 
						destructiveButtonTitle:nil 
						otherButtonTitles:@"Load", @"Save", @"Copy", @"Paste", @"Email", nil];
	else
		actionsSheet = [[UIActionSheet alloc] 
						initWithTitle:@"Action" 
						delegate:self 
						cancelButtonTitle:@"Cancel" 
						destructiveButtonTitle:nil 
						otherButtonTitles:@"Save", @"Copy", @"Email", nil];
	
	actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	// [actionsSheet showInView:self.view];
	[actionsSheet showFromRect:CGRectMake(720, 40, 40, 40) inView:self.view.superview animated:YES];

	[actionsSheet release];
}

@end
