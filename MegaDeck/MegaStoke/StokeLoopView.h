//
//  StokeLoopView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "StokeLoop.h"
#import "InteractiveImageDelegate.h"

@interface StokeLoopView : UIView <InteractiveImageDelegate>
{
	StokeLoop *loop;
	id<InteractiveImageDelegate> delegate;
	
	CADisplayLink	*displayLink;
}

@property (retain) id<InteractiveImageDelegate> delegate;
@property (retain) StokeLoop *loop;

- (id)initWithLoop:(StokeLoop*)loop;

- (int) quantize;
- (void) setQuantize:(int)steps updateExisting:(BOOL)update;

- (void) deselectAll;

@end
