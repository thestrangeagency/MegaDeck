//
//  MDXFade.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/6/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDRibbon.h"

@interface MDXFade : MDRibbon
{
	// indicator boxes
	UIView *aView;
	UIView *bView;
}

// set or change text of labels
- (void) setLabelAText:(NSString*)labelText;
- (void) setLabelBText:(NSString*)labelText;

@end
