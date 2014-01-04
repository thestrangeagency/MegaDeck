//
//  StokeSequencer.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/3/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeSequencer.h"
#import <mach/mach_time.h>
#import <pthread.h>

#define kSleepTime	100000000

@interface StokeSequencer (/* private */)

void thread_signal(int signal);
void *thread_entry(void* argument);
- (void)thread;

@end

@implementation StokeSequencer

- (id) initWithController:(StokeController*)_stokeController
{
    self = [super init];
    if (self) 
	{
		stokeController = _stokeController;
		
		struct mach_timebase_info timebase;
		mach_timebase_info(&timebase);
		hTime2nsFactor = ((double)timebase.numer / (double)timebase.denom) ;
		loopNanos = 1e9 * 2; // 4/4 @ 120 bpm

		pthread_attr_t attr;
		pthread_attr_init(&attr);
		struct sched_param param;
		param.sched_priority = sched_get_priority_max(SCHED_FIFO);
		pthread_attr_setschedparam(&attr, &param);
		pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
		pthread_create(&thread, &attr, thread_entry, (void*)self);
    }
    return self;	
}

- (void) fire
{
//	[stokeController fireFrom:start to:end];
}

void *thread_entry(void* argument)
{
    [(StokeSequencer*)argument thread];
    return NULL;
}

void thread_signal(int signal) 
{
    // ignore
}

- (void)thread 
{
    signal(SIGALRM, thread_signal);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	uint64_t sleepTimeInTicks = (uint64_t)(kSleepTime / hTime2nsFactor);
	
	uint64_t now = mach_absolute_time() * hTime2nsFactor;
	start = (float)now / loopNanos;
	start -= floorf(start);
	
    while ( 1 ) 
	{ 
		uint64_t nextFireTime = mach_absolute_time() + sleepTimeInTicks;
		mach_wait_until(nextFireTime);

		now = mach_absolute_time() * hTime2nsFactor;
		end = (float)now / loopNanos;
		end -= floorf(end);
		
		[self performSelectorOnMainThread:@selector(fire) withObject:nil waitUntilDone:YES];
		
		start = end;
	}
	
	[pool release];
}

@end
