//
//  MDControlGroup.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/20/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDControlPanel.h"

@interface MDControlGroup : NSObject <MDControlDelegate>
{
	MDControlPanel *panel;
}

- (id)initWithPanel:(MDControlPanel*)panel;

@end
