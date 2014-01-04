//
//  SliceView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	Individual slice

#import <UIKit/UIKit.h>
#import "InteractiveImage.h"

@interface SliceView : InteractiveImage
{
    int sliceID;
    int activeHeight;
    int mutedHeight;
    BOOL isMuted;
    UIView *highlightView;
    CGRect originalFrame;
}

@property (nonatomic) int activeHeight;
@property (nonatomic) int mutedHeight;
@property (nonatomic) BOOL isMuted;
@property (nonatomic) int sliceID;

// show grow animation
- (void)trigger;

@end
