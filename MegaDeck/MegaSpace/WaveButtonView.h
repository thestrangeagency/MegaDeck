//
//  WaveButtonView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpaceSynthController.h"

@interface WaveButtonView : UIView
{
	wave	shape;
	wave	table;
	SpaceSynthController *synth;
}

- (id)initWithFrame:(CGRect)frame wave:(wave)_shape table:(wave)_table;

@end
