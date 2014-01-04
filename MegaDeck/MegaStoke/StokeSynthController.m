//
//  StokeSynthController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/4/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeSynthController.h"
#import "StokeVoiceController.h"

@implementation StokeSynthController

- (void) initVoices:(int)nVoices
{
	for( int i=0; i<nVoices; i++ )
	{
		StokeVoiceController *voice = [[StokeVoiceController alloc] initWithSynth:self];
		callbackStructs[i] = [voice renderCallback];
		voice.number = i;
		[voices addObject:voice];
		[voice release];
	}
}

- (void) setLoop:(StokeLoop*)loop
{
	for (StokeVoiceController *voice in voices) 
	{
		[voice setLoop:loop];
	}
}

@end
