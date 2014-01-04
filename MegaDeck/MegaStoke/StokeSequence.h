//
//  StokeSequence.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StokeChannel.h"

@interface StokeSequence : NSObject
{
	NSMutableArray	*channels;	// of StokeChannel
}

// voices are channels, just keeping synth nomenclature
- (id) initWithVoiceCount:(int)nVoices;
- (int) voiceCount;
- (void) clear;

- (void) serialize;
- (void) unserialize;

- (StokeChannel*) channelAtIndex:(int)index;

@end
