//
//  StokeLoop.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/31/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeLoop.h"

/**
	adjust for circular coordinates 0..1
	assuming b is after a
*/
float normalizedDistance(float a, float b)
{
	if( b < a ) b += 1.f;	
	return b - a;
}

void quantizeEvent(StokeEvent* event, LoopStruct loop)
{
	if( loop.steps > 0 )
		event->effective = roundf(event->position * loop.steps) / (float)loop.steps;
	else
		event->effective = event->position;
	
	// printf("%f (%i) => %f \n", event->position, loop.steps, event->effective);
}

StokeEvent *createEvent(float position, float probability, LoopStruct loop)
{
	StokeEvent *event = (StokeEvent*)malloc(sizeof(StokeEvent));
	
	event->position = position;
	event->probability = probability;
	
	event->velocity = .75f;
	event->noteNumber = 0.2f;
	event->grainStart = 0.f;
	event->decay = .1;
	
	event->isActive = YES;
	event->next = NULL;
	
	quantizeEvent(event, loop);
	
	return event;
}

// ---------------------------------------------------------------------------------------------------- Lifecycle
#pragma mark - Lifecycle

@implementation StokeLoop

- (id)init 
{
    self = [super init];
    if (self) 
	{
        loop.head = NULL;
		loop.steps = 0;
		loop.isMuted = NO;
		loop.isProbable = YES;
		loop.level = 1.f;
    }
    return self;
}

- (void)dealloc 
{
    [self clear];
}

// ---------------------------------------------------------------------------------------------------- NSCoding
#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
	NSLog(@"unarchiving loop");
	
    if (self = [super init]) 
	{
		[(NSData*)[decoder decodeObjectForKey:@"loop"] getBytes:&loop length:sizeof(LoopStruct)];
		// clear old pointer
		loop.head = NULL;
		
		NSMutableArray *eventArray = [decoder decodeObjectForKey:@"events"];
		StokeEvent *lastEvent = NULL;
		
		if( eventArray )
			NSLog(@"array found with %i events",[eventArray count]);
		
		for (NSData *eventData in eventArray) 
		{
			StokeEvent *event = (StokeEvent*)malloc(sizeof(StokeEvent));
			[eventData getBytes:event length:sizeof(StokeEvent)];
			// clear old pointer
			event->next = NULL;
			
			if( lastEvent )
				lastEvent->next = event;
			
			lastEvent = event;
			
			if( loop.head == NULL )
				loop.head = event;
		}
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:[NSData dataWithBytes:&loop length:sizeof(LoopStruct)] forKey:@"loop"];
	
	StokeEvent *event = loop.head;
	if( event )
	{
		NSMutableArray *eventArray = [NSMutableArray array];
		do
		{
			[eventArray addObject:[NSData dataWithBytes:event length:sizeof(StokeEvent)]]; 
		}
		while ((event = event->next));
		[encoder encodeObject:eventArray forKey:@"events"];
	}
}

// ---------------------------------------------------------------------------------------------------- events
#pragma mark - events

// interpolate params of neighboring events

- (void) linterpEvent:(StokeEvent*)event
{
	StokeEvent *a = [self eventBefore:event];
	StokeEvent *b = [self eventAfter:event];
	
	if( a && b && ( a != b ) )
	{
		float distance = normalizedDistance(a->position, b->position);
		float aPortion = 1.f - normalizedDistance(a->position, event->position)/distance;
		float bPortion = 1.f - normalizedDistance(event->position, b->position)/distance;
		
		NSLog(@"interpolation %f [%f : %f]",distance,aPortion,bPortion);
		NSLog(@"%f : %f",normalizedDistance(a->position, event->position), normalizedDistance(event->position, b->position));
		
		event->velocity		= a->velocity	* aPortion + b->velocity	* bPortion;
		event->noteNumber	= a->noteNumber * aPortion + b->noteNumber	* bPortion;
		event->grainStart	= a->grainStart * aPortion + b->grainStart	* bPortion;
		event->decay		= a->decay		* aPortion + b->decay		* bPortion;
	}
}

- (StokeEvent*) addEventAt:(float)position withProbability:(float)probabilty
{
	if( loop.head == NULL )
	{
		loop.head = createEvent(position, probabilty, loop);
		return loop.head;
	}
	else
	{
		StokeEvent *event = loop.head;
		while (event->next != NULL) 
		{
			event = event->next;
		}
		event->next = createEvent(position, probabilty, loop);
		
		[self linterpEvent:event->next];
		
		return event->next;
	}
}

- (void) setEvent:(StokeEvent*)event at:(float)position withProbability:(float)probability
{
	event->position = position;
	event->probability = probability;
	quantizeEvent(event, loop);
}

// TODO reimplement with doubly linked list?

- (StokeEvent*) eventBefore:(StokeEvent*)event
{
	StokeEvent *temp = loop.head;
	StokeEvent *high = NULL;
	float lowestDistance = 1.f;
	if( temp )
		do
		{
			if( event == temp ) continue;
			float distance = normalizedDistance(temp->position, event->position);
			if( distance < lowestDistance )
			{
				high = temp;
				lowestDistance = distance;
			}
		}
	while ((temp = temp->next));
	
	return high;
}

- (StokeEvent*) eventAfter:(StokeEvent*)event
{
	StokeEvent *temp = loop.head;
	StokeEvent *low = NULL;
	float lowestDistance = 1.f;
	if( temp )
		do
		{
			if( event == temp ) continue;
			float distance = normalizedDistance(event->position, temp->position);
			if( distance < lowestDistance )
			{
				low = temp;
				lowestDistance = distance;
			}
		}
	while ((temp = temp->next));
	
	return low;
}

- (void) removeEvent:(StokeEvent*)remove
{
	StokeEvent *event = loop.head;
	if( remove == event )
		loop.head = event->next;
	else
		do
		{
			if( remove == event->next )
				event->next = remove->next;
		}
		while ((event = event->next));
	free(remove);
}

- (StokeEvent*) head
{
	return loop.head;
}

// ---------------------------------------------------------------------------------------------------- properties
#pragma mark - properties

- (BOOL) isMuted
{
	return loop.isMuted;
}

- (void) setIsMuted:(BOOL)mute
{
	loop.isMuted = mute;
}

- (BOOL) isProbable
{
	return loop.isProbable;
}

- (void) setIsProbable:(BOOL)probalate
{
	loop.isProbable = probalate;
}

- (int) quantize
{
	return loop.steps;
}

- (void) setQuantize:(int)steps
{
	loop.steps = steps;
	StokeEvent *event = loop.head;
	if( event )
		do
		{
			quantizeEvent(event, loop);
		}
		while ((event = event->next));
}

- (void) clear
{
	StokeEvent *event = loop.head;
	loop.head = NULL;
	while (event) 
	{
		StokeEvent *temp = event;
		event = event->next;
		free(temp);
	}
}

- (float) level
{
	return loop.level;
}

- (void) setLevel:(float)level
{
	loop.level = level;
}

- (NSString *)description
{
	NSString *desc = @"StokeLoop";
	StokeEvent *event = loop.head;
	if( event )
		do
		{
			desc = [desc stringByAppendingString:[NSString stringWithFormat:@" [%f,%f]",event->position, event->probability]];
		}
		while ((event = event->next));
	return desc;
}

@end
