//
//  MDKeyModel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/16/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDKeyModel.h"
#import "SynthesizeSingleton.h"
#import "MDAppDelegate.h"

int blackMask =	0b0000010100101010;

@implementation MDKeyModel

SYNTHESIZE_SINGLETON_FOR_CLASS(MDKeyModel);

@synthesize notes, fatKeys, baseOctave;

// ---------------------------------------------------------------------------------------------------- state
#pragma mark - state

- (void) serialize
{
	NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:
						   scaleKey,							@"scaleKey",
						   [NSNumber numberWithInt:baseOctave],	@"baseOctave",
						   [NSNumber numberWithBool:fatKeys],	@"fatKeys",
						   [NSNumber numberWithInt:root],		@"root",
						   nil];
	[[NSUserDefaults standardUserDefaults] setObject:state forKey:@"MDKeyModel"];	
}

- (void) unserialize
{
	NSDictionary *state = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MDKeyModel"];
	if (state) 
	{
		[self setScale:		[state objectForKey:@"scaleKey"]];
		baseOctave =		[[state objectForKey:@"baseOctave"] intValue];
		[self setFatKeys:	[[state objectForKey:@"fatKeys"] boolValue]];
		[self setRoot:		[[state objectForKey:@"root"] intValue]];
	}
}

// ----------------------------------------------------------------------------------------------------

- (id)init 
{
    self = [super init];
    if (self) 
	{
        scales = [[OrderedDictionary alloc] init];
		
//		[scales setObject:[NSNumber numberWithInt:0b0000] forKey:@""];
		
		[scales setObject:[NSNumber numberWithInt:0b0000111111111111] forKey:@"chromatic"];
		[scales setObject:[NSNumber numberWithInt:0b0000101011010101] forKey:@"major"];
		[scales setObject:[NSNumber numberWithInt:0b0000101101011001] forKey:@"harm minor"];
		[scales setObject:[NSNumber numberWithInt:0b0000101101011010] forKey:@"nat minor"];
		
		if( [[MDAppDelegate sharedAppDelegate] isPaid] )
		{
			[scales setObject:[NSNumber numberWithInt:0b0000101011010101] forKey:@"ionian"];
			[scales setObject:[NSNumber numberWithInt:0b0000101101010110] forKey:@"dorian"];
			[scales setObject:[NSNumber numberWithInt:0b0000110101011010] forKey:@"phrygian"];
			[scales setObject:[NSNumber numberWithInt:0b0000101010110101] forKey:@"lydian"];
			[scales setObject:[NSNumber numberWithInt:0b0000101011010110] forKey:@"mixolydian"];
			[scales setObject:[NSNumber numberWithInt:0b0000101101011010] forKey:@"aeolian"];
			[scales setObject:[NSNumber numberWithInt:0b0000110101101010] forKey:@"locrian"];
		}
		
		[scales setObject:[NSNumber numberWithInt:0b0000100110010110] forKey:@"maj blues"];
		[scales setObject:[NSNumber numberWithInt:0b0000100101110010] forKey:@"min blues"];
		
		[scales setObject:[NSNumber numberWithInt:0b0000101010010100] forKey:@"maj penta"];
		[scales setObject:[NSNumber numberWithInt:0b0000010010101001] forKey:@"min penta"];
		
		[scales setObject:[NSNumber numberWithInt:0b0000101100111001] forKey:@"gypsy"];
		[scales setObject:[NSNumber numberWithInt:0b0000101001010010] forKey:@"egyptian"];
		[scales setObject:[NSNumber numberWithInt:0b0000100011010001] forKey:@"ryukyu"];

		[scales setObject:[NSNumber numberWithInt:0b0000101010101010] forKey:@"wholetone"];
		[scales setObject:[NSNumber numberWithInt:0b0000100010001000] forKey:@"maj third"];
		[scales setObject:[NSNumber numberWithInt:0b0000100100100100] forKey:@"min third"];
		[scales setObject:[NSNumber numberWithInt:0b0000100000010000] forKey:@"fifth"];
	
		[self setScale:@"chromatic"];
		[self setRoot:0];
		
		fatKeys = NO;
		baseOctave = 4;
		
		[self unserialize];
    }
    return self;
}

- (void)dealloc 
{
    [self serialize];
    [super dealloc];
}

- (void) countNotes
{
	// count notes (per octave) in scale
	int copy = scale;
	for (notes = 0; copy; copy >>= 1)
	{
		notes += copy & 1;
	}
}

- (int) root
{
	return root;
}

- (void) setRoot:(int)halfSteps
{
	NSLog(@"MDKeyModel setRoot:%@", [[self roots] objectAtIndex:halfSteps]);
	scale = [[scales objectForKey:scaleKey] intValue];
	for( int i=0; i < halfSteps; i++ )
	{
		int lastBit = scale & 1;
		scale = (scale >> 1) & 0b0000011111111111;
		scale = scale | (lastBit << 11);
	}
	root = halfSteps;
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_KEY_CHANGE object:self];
}

- (NSString*) scale
{
	return scaleKey;
}

- (void) setFatKeys:(BOOL)_fatKeys
{
	fatKeys = _fatKeys;
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_KEY_CHANGE object:self];
}

- (void) setScale:(NSString*)key
{
	NSLog(@"MDKeyModel setScale:%@",key);
	scaleKey = key;
	scale = [[scales objectForKey:key] intValue];
	[self countNotes];
	[self setRoot:root];
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_KEY_CHANGE object:self];
}

- (void) setScaleWithMask:(int)mask
{
	scale = mask;
	scaleKey = @"";
	root = 0;
	[self countNotes];
	[[NSNotificationCenter defaultCenter] postNotificationName:MD_KEY_CHANGE object:self];
}

- (NSArray *) scales
{
	return [scales allKeys];
}

- (NSString *) scaleAtIndex:(int)index
{
	return [scales keyAtIndex:index];
}

- (int) indexForScale
{
	return [self indexForScale:scaleKey];
}

- (int) indexForScale:(NSString*)key
{
	return [scales indexOfObject:key];
}

- (NSArray *) roots
{
	return [NSArray arrayWithObjects:
			@"C",
			@"C#",
			@"D",
			@"D#",
			@"E",
			@"F",
			@"F#",
			@"G",
			@"G#",
			@"A",
			@"A#",
			@"B",
			nil];
}

- (void) shiftUp
{
	if( baseOctave < 9 ) baseOctave++;
}

- (void) shiftDown
{
	if( baseOctave > 0 ) baseOctave--;
}

- (int) octaveAtIndex:(int)index
{
	return floorf((float)index/notes);
}

- (int) octaveAtIndexMIDI:(int)index;
{
	return [self octaveAtIndex:index] - 5;
}

- (int) scaleDegreeAtIndex:(int)index
{
	int degree = index % notes;
	
	int scaleDegree = 0;
	int copy = scale;
	
	for (int i=0; i < 12; copy <<= 1)
	{
		degree -= copy & 0b0000100000000000 ? 1 : 0;
		if( degree >= 0 )
			scaleDegree++;
		else
			break;
	}
	
	return scaleDegree;
}

- (int) noteNumberAtIndex:(int)index
{
	return 12*[self octaveAtIndex:index] + [self scaleDegreeAtIndex:index];
}

- (int) blackAtIndex:(int)index
{
	return blackMask & (0b0000100000000000 >> [self scaleDegreeAtIndex:index]);
}

- (NSString*) noteNameWithPitchClass:(int)pitchClass
{
	const NSString *pitchNames =	 @"CCDDEFFGGAAB";
	const NSString *pitchOrnaments = @" # #  # # # ";
	
	return [NSString stringWithFormat:@"%c%c", 
			[pitchNames characterAtIndex:pitchClass],
			[pitchOrnaments characterAtIndex:pitchClass]];
}

- (NSString*) noteNameWithNoteNumber:(int)noteNumber
{
	int pitchClass = noteNumber % 12;	
	return [self noteNameWithPitchClass:pitchClass];
}

@end
