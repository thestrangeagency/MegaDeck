//
//  SliceController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSAGeneratorProtocol.h"

@class SliceLoopModel;

@interface SliceController : NSObject <TSAGeneratorProtocol>
{
	NSMutableArray	*loops; // array of SliceLoopModel
	UInt16			soloMask;
	int				soloIndex;
}

- (SliceLoopModel*)loop:(int)index;

- (void) setLevel:(float)level forLoop:(int)index;
- (float) levelForLoop:(int)index;
- (void) mute:(int)index;
- (void) unmute:(int)index;
- (BOOL) isMuted:(int)index;
- (void) solo:(int)index;
- (void) unsolo;
- (BOOL) isSolo:(int)index;
- (NSString*) lastPath:(int)index;

- (void) setXFade:(float)xFade;


@property (nonatomic, retain) NSMutableArray *loops;

@end
