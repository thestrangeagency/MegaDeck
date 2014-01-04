//
//  StokeController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StokeSequence.h"
#import "TSAGraphProtocol.h"
#import "TSASynthController.h"

@interface StokeController : NSObject
{
	StokeSequence	*sequence;	// sequence model
	NSMutableArray	*channels;	// of GrainSynthController
}

@property (readonly) StokeSequence	*sequence;

// TSAGeneratorProtocol - voices are channels, just keeping synth nomenclature
- (id) initWithVoiceCount:(int)nVoices;
- (int) voiceCount;
- (void) attachToGraph:(id<TSAGraphProtocol>)graph;

- (TSASynthController*) synthForChannel:(int)channel;

- (void)serialize;
- (void)unserialize;

@end
