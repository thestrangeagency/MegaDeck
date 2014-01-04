//
//  MDKeyControlPanel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/16/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDControlPanel.h"
#import "MDControlSlider.h"

@interface MDKeyControlPanel : MDControlPanel <UIPickerViewDelegate, UIPickerViewDataSource>
{
	IBOutlet UIPickerView *pickerView;

	MDInverseButton *fatKeysButton;	
}

@end
