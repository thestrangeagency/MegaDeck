//
//  SliceLoopModel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/29/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDSoundModel.h"
#import "MDTransportModel.h"

#define N_SLICES	16
#define N_ROWS      4
#define N_COLUMNS   4

@class SliceView, SliceLoopModel, SliceLoopView;

typedef struct 
{
	int startTime;
	BOOL isActive; // active means not muted
	BOOL isNew;
    SliceView *sliceView;
} SliceStruct;

typedef struct
{
	float gain;
	
	int		offset;				// samples, within current slice
	float	floatOffset;		// samples, but fractional
	int		sliceLength;
	int		currentSlice;
    int		currentPosition;
    
    BOOL	isEmpty;
	BOOL	isMuted;
	
	// buffer traversal
	float	bars;
	float	speed;			// samples per frame
	float	speedMultiplier;
	
	// sound model pointers
	UInt32	*audioData;
	SInt64	*startPtr;
	UInt32	*lengthPtr;
	
	// subloop control
	UInt32	fraction;	// of the loop
	UInt32	index;		// of sub loop
	
    int			sliceIndexes[N_SLICES];
	SliceStruct slices[N_SLICES];
	
	TransportModel	*transportModel;
} LoopStruct;

@interface SliceLoopModel : NSObject
{
	MDSoundModel	*soundModel;
	TransportModel	*transportModel;
	LoopStruct		loop;
	NSMutableArray	*sliceViews;
	
	AURenderCallbackStruct renderCallback;
}

@property (readonly) AURenderCallbackStruct renderCallback;
@property (nonatomic) float gain;
@property (nonatomic) BOOL isMuted;
@property (readonly) MDSoundModel* soundModel;
@property (nonatomic, retain) NSMutableArray *sliceViews;
@property (nonatomic, assign) LoopStruct loop; 
@property (copy, readonly) NSString *lastPath;

- (void) setKeyAndReload:(NSString*)key;
- (SliceStruct*) sliceAtIndex:(int)index;
- (SliceStruct*) currentSlice;

- (SliceStruct*) currentPositionSlice; // is this even meaningful?

- (void) setFraction:(int)fraction withIndex:(int)index;
- (void) doubleSpeed;
- (void) halveSpeed;
- (void) restart;

@end
