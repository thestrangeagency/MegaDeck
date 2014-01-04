//
//  SliceLoopView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliceLoopModel.h"
#import "InteractiveImageDelegate.h"

@interface SliceLoopView : UIView <InteractiveImageDelegate>
{
	SliceLoopModel	*loopModel;
	NSMutableArray	*sliceViews;
    NSMutableArray *sliceActiveStatesStack;
    NSMutableArray *currentTouches;
    SliceView *currentlyDraggedSlice;
    int indexPlayingSlice;
}

- (id)initWithFrame:(CGRect)frame loop:(SliceLoopModel*)model;
- (void)resetSlices;
- (void)moveSliceToActivePosition:(SliceView *)slice;
- (void)killTouches;
- (void)unmuteAll;
- (void)setModel:(SliceLoopModel*)model;

@property (nonatomic, retain) NSMutableArray *sliceViews;
@property (nonatomic, retain) SliceView *currentlyDraggedSlice;

@end
