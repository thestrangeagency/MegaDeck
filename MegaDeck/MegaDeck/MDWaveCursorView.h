//
//  MDWaveCursorView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//  view for displaying a sound model with a cursor

#import <Foundation/Foundation.h>
#import "MDSoundModel.h"
#import "MDWaveView.h"

// -----------------------------------------------------------------------

@protocol MDWaveViewDelegate <NSObject>

- (void) waveViewDidChange;

@optional

// called only if animating
- (float) positionFraction;

@end

// -----------------------------------------------------------------------

@interface MDWaveCursorView : MDWaveView
{	
	CGPoint location;
	UIView *cursor;
	UIActivityIndicatorView *activityView;
	
	id<MDWaveViewDelegate> delegate;
	
	BOOL isLive;
}

// -----------------------------------------------------------------------

@property (retain) id<MDWaveViewDelegate> delegate;

@property float positionFraction;

// set to YES to recalc wave view at each frame
@property BOOL isLive;

- (void) suspend;
- (void) reset;

- (void) setCursorHidden:(BOOL)shouldHide;

// protected
- (void) updateCursor;

@end
