//
//  StokeChannel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSoundModel.h"
#import "StokeLoop.h"

@interface StokeChannel : NSObject <NSCoding>
{
	MDSoundModel	*soundModel;
	StokeLoop		*loop;
}

@property (readonly) MDSoundModel	*soundModel;
@property (readonly) StokeLoop		*loop;

@property (nonatomic) float			level;

- (void) clear;

@end
