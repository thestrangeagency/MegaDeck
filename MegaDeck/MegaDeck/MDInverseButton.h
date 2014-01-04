//
//  MDInverseButton.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/17/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDInverseButton : UIButton
{
	UILabel *auxLabel;
}

// adds (or sets) auxilliary label text
- (void) addLabelText:(NSString*)labelText;

@end
