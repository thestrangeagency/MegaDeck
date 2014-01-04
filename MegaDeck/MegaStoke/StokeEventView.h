//
//  StokeEventView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "InteractiveImage.h"
#import "StokeLoop.h"

@interface StokeEventView : InteractiveImage
{
	StokeEvent* event;
}

@property StokeEvent* event;

- (void) refresh;

// sequence status
- (void) update;

@end
