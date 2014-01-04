//
//  MDHelpView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 7/23/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDHelpMarker.h"

typedef enum
{
	dots,
	text,
} HelpMode;

@interface MDHelpView : UIView
{
	NSDictionary	*helpDictionary;
	UITextView		*textView;
	UITextView		*footerTextView;
	UIView			*screen;
	HelpMode		mode;
}

- (id)initWithPlist:(NSString*)listName;
- (void) touchMarker:(MDHelpMarker*)marker;

@end
