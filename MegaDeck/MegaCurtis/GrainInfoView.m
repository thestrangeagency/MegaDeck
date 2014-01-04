//
//  GrainInfoView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/11/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainInfoView.h"
#import "GrainSynthController.h"
#import "GrainVectorView.h"
#import "MegaCurtisAppDelegate.h"

@implementation GrainInfoView

- (void) initVoiceViews
{
	GrainSynthController *synth = (GrainSynthController*)[[MegaCurtisAppDelegate sharedAppDelegate] synth];
	
	voiceViews = [[NSMutableArray arrayWithCapacity:synth.voices.count] retain];
	int i = 0;
	CGRect rect = CGRectMake(0, 0, 20, 20);
	for (GrainVoiceController *voice in synth.voices) 
	{
		rect.origin.x = 120 + 76 * (i % 2);
		rect.origin.y =   8 + 84 * floorf(i / 2);
		i++;
		
		GrainVectorView *grainView = [[GrainVectorView alloc] initWithFrame:rect];
		grainView.grainVoice = voice.grainVoice;
		[voiceViews addObject:grainView];
		[self addSubview:grainView];
	}
}

- (void) refresh
{
	if( voiceViews )
		for( GrainVectorView *grainView in voiceViews )
		{
			[grainView refresh];
		}
}

- (void) setAX:(float)value
{
	[auxAXView setBackgroundColor:[UIColor colorWithRed:value green:value blue:value alpha:1]];
}

- (void) setBX:(float)value
{
	[auxBXView setBackgroundColor:[UIColor colorWithRed:value green:value blue:value alpha:1]];
}

- (void) setBY:(float)value
{
	[auxBYView setBackgroundColor:[UIColor colorWithRed:value green:value blue:value alpha:1]];
}

- (void) hideBLabels:(BOOL)shouldHide
{
	[auxBXLabel setHidden:shouldHide];
	[auxBYLabel setHidden:shouldHide];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self initVoiceViews];
	[self setUserInteractionEnabled:NO];
	if( [[NSUserDefaults standardUserDefaults] boolForKey:@"portrait_x_pitch"] )
		[auxAXLabel setText:@"grain_size"];
}

- (void)dealloc
{
	[voiceViews release];	
    [super dealloc];
}

@end
