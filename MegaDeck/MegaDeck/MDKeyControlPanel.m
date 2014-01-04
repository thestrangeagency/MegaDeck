//
//  MDKeyControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/16/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDKeyControlPanel.h"
#import "MDKeyModel.h"
#import <QuartzCore/QuartzCore.h>
#import "MDAppDelegate.h"

@implementation MDKeyControlPanel

- (void) didMoveToSuperview
{
	[pickerView selectRow:[[MDKeyModel sharedMDKeyModel] indexForScale] inComponent:0 animated:NO];
	[pickerView selectRow:[[MDKeyModel sharedMDKeyModel] root] inComponent:1 animated:NO];
	NSLog(@" picker:%@, scale:%i, root:%i",pickerView, [[MDKeyModel sharedMDKeyModel] indexForScale], [[MDKeyModel sharedMDKeyModel] root]);
	
	CALayer* mask = [[CALayer alloc] init];
	[mask setBackgroundColor: [UIColor blackColor].CGColor];
	[mask setFrame: CGRectMake(12, 10, pickerView.frame.size.width-22, pickerView.frame.size.height-20)];
	[mask setCornerRadius: 5.0f];
	[pickerView.layer setMask: mask];
	[mask release];
	
	fatKeysButton = [[self putButtonInSlot:0 withTitle:@"FAT" selector:@selector(touchFat)] retain];
	[fatKeysButton setSelected:[[MDKeyModel sharedMDKeyModel] fatKeys]];
}

- (void) touchFat
{
	fatKeysButton.selected = !fatKeysButton.selected;
	[[MDKeyModel sharedMDKeyModel] setFatKeys:fatKeysButton.selected];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)_pickerView
{
	return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if( component == 0 )
	{
		return 202-48; // 202 is measured picker interior in nib
	}
	else
	{
		return 48;
	}
}

- (NSInteger)pickerView:(UIPickerView *)_pickerView numberOfRowsInComponent:(NSInteger)component 
{
	if( component == 0 )
	{
		return [[[MDKeyModel sharedMDKeyModel] scales] count];
	}
	else
	{
		return [[[MDKeyModel sharedMDKeyModel] roots] count];
	}
}

- (NSString *)pickerView:(UIPickerView *)_pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if( component == 0 )
	{
		return [[[MDKeyModel sharedMDKeyModel] scaleAtIndex:row] uppercaseString];
	}
	else
	{
		return [[[MDKeyModel sharedMDKeyModel] roots] objectAtIndex:row];
	}
}

- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if( component == 0 )
	{
		[[MDKeyModel sharedMDKeyModel] setScale:[[MDKeyModel sharedMDKeyModel] scaleAtIndex:row]];
	}
	else
	{
		[[MDKeyModel sharedMDKeyModel] setRoot:row];
	}
}

- (void)dealloc 
{
    [pickerView release];
	[fatKeysButton release];
    [super dealloc];
}

@end
