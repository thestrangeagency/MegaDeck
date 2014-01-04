//
//  WaveSelectorView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveButtonView.h"

@interface WaveSelectorView : UIView
{
	wave	table;
}

- (id)initWithFrame:(CGRect)frame table:(wave)_table;

@end
