//
//  MDKeyModel.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/16/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"
#import "NSObject+Persistant.h"

#define MD_KEY_CHANGE	@"MD_KEY_CHANGE"

@protocol MDKeyModelProtocol <NSObject>

- (void)keyChanged;

@end

// --------------------------------------------------------------------------

@interface MDKeyModel : NSObject
{
	OrderedDictionary *scales;
	
	NSString *scaleKey;	// dictionary key for current scale (since int below mutates with root change)
	int scale;			// current scale, as bitmask (rotated by root)
	int notes;			// pitch classes in this scale
	int root;			// halfsteps from C
	int	baseOctave;		// current MIDI octave
	BOOL fatKeys;
}

@property (nonatomic, copy) NSString *scale;
@property (nonatomic) int root;
@property (readonly) int notes;
@property (nonatomic) BOOL fatKeys;
@property (readonly) int baseOctave;

+ (MDKeyModel*) sharedMDKeyModel;

/**
 * index is integer offset from first note in scale
 * return value factors in the baseOctave
 */
- (int) octaveAtIndex:(int)index;
- (int) octaveAtIndexMIDI:(int)index;
- (int) noteNumberAtIndex:(int)index;
- (int) blackAtIndex:(int)index;

/**
 * ordered dictionary index access
 */
- (int) indexForScale;
- (int) indexForScale:(NSString*)key;

- (NSString *) scaleAtIndex:(int)index;
- (NSArray *) scales; // unordered
- (NSArray *) roots;

- (void) shiftUp;
- (void) shiftDown;

// set manual scale with a bitmask
- (void) setScaleWithMask:(int)mask;

// utilities
- (NSString*) noteNameWithPitchClass:(int)pitchClass;
- (NSString*) noteNameWithNoteNumber:(int)noteNumber;

@end
