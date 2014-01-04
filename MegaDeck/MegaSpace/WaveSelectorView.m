//
//  WaveSelectorView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "WaveSelectorView.h"

@implementation WaveSelectorView

- (id)initWithFrame:(CGRect)frame table:(wave)_table
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        table = _table;
		
		for( int i = 0; i < 7; i++ )
		{
			float w = 224.f/7.f;
			WaveButtonView *waveButton = [[WaveButtonView alloc] initWithFrame:CGRectMake(w * i, 0, w, 48) 
																		  wave:i > FLAT ? (i+3) : i 
																		 table:table];
			[self addSubview:waveButton];
		}
		
    }
    return self;
}

@end
