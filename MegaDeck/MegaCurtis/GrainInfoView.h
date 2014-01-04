//
//  GrainInfoView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/11/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDLabel.h"

@interface GrainInfoView : UIView
{
	NSMutableArray			*voiceViews;
	
	// IBOutlet UIView		*cursor;
	
	IBOutlet MDLabel	*auxAXLabel;
	IBOutlet UIView		*auxAXView;
	
	IBOutlet MDLabel	*auxBXLabel;
	IBOutlet UIView		*auxBXView;

	IBOutlet MDLabel	*auxBYLabel;
	IBOutlet UIView		*auxBYView;
}

- (void) refresh;
- (void) setAX:(float)value;
- (void) setBX:(float)value;
- (void) setBY:(float)value;
- (void) hideBLabels:(BOOL)shouldHide;

@end
