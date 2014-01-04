//
//  MDTransportModel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/12/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	Use me for tempo control

#import <Foundation/Foundation.h>

#define MD_TRANSPORT_NOTIFICATION	@"MD_TRANSPORT_NOTIFICATION"

typedef struct 
{
	float	bpm;
	BOOL	isPlaying;
} TransportModel;

@interface MDTransportModel : NSObject
{
	TransportModel model;
}

@property (readonly) TransportModel *model;
@property float bpm;

+ (MDTransportModel*) sharedMDTransportModel;

- (void) play;
- (void) stop;

@end
