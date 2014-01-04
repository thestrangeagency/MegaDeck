//
//  StokeVoiceController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/4/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainVoiceController.h"
#import "StokeLoop.h"
#import "MDTransportModel.h"

typedef struct
{
	Float64	mSampleTime;
	UInt32	inNumberFrames;
} TimeStruct;

@interface StokeVoiceController : GrainVoiceController
{
	StokeLoop *loop;
	TransportModel *transport;
}

- (void) setLoop:(StokeLoop*)loop;

@end
