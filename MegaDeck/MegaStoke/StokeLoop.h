//
//  StokeLoop.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_LOOP_EVENTS		32;

struct event
{
	float position;		// loop position
	float effective;	// quantized loop position
	float probability;

	float velocity;
	float noteNumber;
	float grainStart;
	float decay;
	
	BOOL isTriggered;
	BOOL isSkipped;		// probabilty too low
	
	BOOL isActive;
	struct event *next;
};

typedef struct event StokeEvent;

typedef struct
{	
	StokeEvent	*head;	
	int			steps;			// quantize
	BOOL		isMuted;
	BOOL		isProbable;		// to disable probability drive
	float		level;
} LoopStruct;

@interface StokeLoop : NSObject <NSCoding>
{
	LoopStruct loop;
}

@property (nonatomic) BOOL	isMuted;
@property (nonatomic) BOOL	isProbable;
@property (nonatomic) int	quantize;
@property (nonatomic) float	level;

- (StokeEvent*) addEventAt:(float)position withProbability:(float)probabilty;
- (void) setEvent:(StokeEvent*)event at:(float)position withProbability:(float)probability;
- (void) removeEvent:(StokeEvent*)event;
- (StokeEvent*) head;
- (void) clear;

// get events ordered by event->position (not list position!)
- (StokeEvent*) eventBefore:(StokeEvent*)event;
- (StokeEvent*) eventAfter:(StokeEvent*)event;

@end
