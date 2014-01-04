//
//  MDMidi.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/18/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDMidi.h"
#import "PGMidi.h"
#import "TSASynthController.h"
#import "MDAppDelegate.h"
#import "LNCStopwatch.h"
#import "TSACoreGraph+Control.h"
#import "TSACoreFeedback.h"

@interface MDMidi () <PGMidiDelegate, PGMidiSourceDelegate>

- (void) attachToAllExistingSources;

@end

// ---------------------------------------------------------------------------------------------------- 
#pragma mark -

@implementation MDMidi

@synthesize midi, synth, graph;

- (id) init
{
	self = [super init];
    if (self)
	{
		graph = [[MDAppDelegate sharedAppDelegate] graph];
		synth = [[MDAppDelegate sharedAppDelegate] synth];
		echo = [[MDAppDelegate sharedAppDelegate] echo];
		
		midi = [[PGMidi alloc] init];
        [midi enableNetwork:YES];
		midi.delegate = self;
		[self attachToAllExistingSources];
		
		tickTimer = [[LNCStopwatch alloc] init];
	}
	return self;
}

- (void)dealloc 
{
	midi.delegate = nil;
    [midi release];
    [super dealloc];
}

// ---------------------------------------------------------------------------------------------------- 
#pragma mark -

- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source{}
- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source{}
- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination{}
- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination{}

- (NSString *) stringFromPacket:(const MIDIPacket *)packet
{
    return [NSString stringWithFormat:@"%u bytes: [%02x,%02x,%02x] bpm:%2.2f %f",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0,
			bpm, avgTickElapsed
			];
}

- (void) noteNumberPressed
{
	[synth notePressed:(int)message[1] withVelocity:(int)message[2]];
}

- (void) noteNumberReleased
{
	[synth noteReleased:(int)message[1]];
}

// ---------------------------------------------------------------------------------------------------- midi thread
#pragma mark - midi thread

#define TICKS_PER_QUARTER	24	

- (void) tapTick
{
	avgTickElapsed = avgTickElapsed == 0 ? [tickTimer elapsedSeconds] : .9 * avgTickElapsed + .1 * [tickTimer elapsedSeconds];
	[tickTimer restart];
	
	bpm = 1.0 / ((avgTickElapsed / 60.0) * TICKS_PER_QUARTER);
}

- (void) controller:(int)number value:(int)value
{
	float floatValue = value/127.f;
	
	switch (number) 
	{
		// all notes off
		case 0x7b: 
			[synth panic];
			break;
			
		// portamento
		case 5:
			[synth setPortamentoRate:1.f - floatValue];
			break;
			
		// filter
		case 74:
			[graph setFilterCutoff:floatValue];
			break;
		case 71:
			[graph setFilterResonance:floatValue];
			break;
		
		// echo
		case 12:
			[echo setDelayLevel:floatValue];;
			break;
		case 13:
			[echo setDelayLengthFraction:floatValue];
			break;
			
		// envelope
		case 73:
			[synth setAmpAttack:floatValue];
			break;
		case 75:
			[synth setAmpDecay:floatValue];
			break;
		case 72:
			[synth setAmpRelease:floatValue];
			break;
			
		// vibrato
		case 76:
			[synth setVibratoPeriod:floatValue];
			break;
		case 77:
			[synth setVibratoDepth:floatValue];
			break;
			
		default:
			break;
	}
}

- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{	
    const MIDIPacket *packet = &packetList->packet[0];
	
    for (int i = 0; i < packetList->numPackets; ++i)
    {
		//	NSLog(@"%@",[self stringFromPacket:packet]);
		
		message = &packet->data[0];
		UInt16 length = packet->length;
		int index = 0;

		do 
		{
			// find next status byte
			if( message[index] < 0x80 ) continue;
			
			message = &message[index];

			// tick
			if( message[0] == 0xF8 )
				[self tapTick];
			
			// controller
			else if( message[0] == 0xB0 )
				[self controller:message[1] value:message[2]];
			
			// note off (can be note on with vel 0)
			else if( message[0] == 0x80 || ( message[0] == 0x90 && message[2] == 0x00 ) )
				[self performSelectorOnMainThread:@selector(noteNumberReleased) 
									   withObject:nil
									waitUntilDone:YES];
			
			// note on
			else if( message[0] == 0x90 )
				[self performSelectorOnMainThread:@selector(noteNumberPressed) 
									   withObject:nil
									waitUntilDone:YES];
			
			// start or restart
			else if( message[0] == 0xFA || message[0] == 0xFB )
			{
				avgTickElapsed = 0;
				[tickTimer restart];
			}
			
			// stop
			else if( message[0] == 0xFC )
			{
				[tickTimer stop];
				[synth panic];
			}

		} while (++index < length);

		
        packet = MIDIPacketNext(packet);
    }
}

@end
