//
//  MDKeyboardView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/4/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSASynthProtocol.h"
#import "MDKeyView.h"

#define KEYBOARD_SHOWING	@"KEYBOARD_SHOWING"

@interface MDKeyboardView : UIView <MDKeyProtocol>
{
	MDKeyView *keyView;
	IBOutlet UILabel *noteLabel;
	NSString *pitchNames;
	NSString *pitchOrnaments;
	id<TSASynthProtocol> delegate;
}

@property (retain) id<TSASynthProtocol> delegate;

- (IBAction) shiftUp;
- (IBAction) shiftDown;
- (IBAction) toggleShowing;

- (void) hide;

@end
