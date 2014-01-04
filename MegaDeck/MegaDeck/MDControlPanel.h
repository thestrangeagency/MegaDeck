//
//  MDControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//
//	Collection of controls

#import <UIKit/UIKit.h>
#import "MDControl.h"
#import "MDInverseButton.h"

@interface MDControlPanel : UIView <MDControlDelegate>
{
	int nSlots;
}

@property int nSlots;

- (CGRect) rectForSlot:(int)slot;
- (CGRect) nextSlotRect;
- (CGRect) btnRectForSlot:(int)slot;

- (MDInverseButton*) putButtonInSlot:(int)slot withTitle:(NSString*)title selector:(SEL)selector;

@end
