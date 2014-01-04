//
//  MDCAppDelegate.h
//  MegaCurtis
//
//  Created by Lucas Kuzma on 2/17/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDAppDelegate.h"

#undef  MD_SHARE_MESSAGE
#define MD_SHARE_MESSAGE	@"Check out this strange sound I made with MegaCurtis!"

@interface MegaCurtisAppDelegate : MDAppDelegate <SynthControllerDelegate>

@end
