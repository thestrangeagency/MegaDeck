//
//  MDControl.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDControl.h"
#import "MathUtil.h"

@implementation MDControl

@synthesize delegate = _delegate;
@synthesize taper, reverse;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self setBackgroundColor:[UIColor blackColor]];
		[self setMultipleTouchEnabled:NO];
		[self setUserInteractionEnabled:YES];
		
		taper = linear;
		reverse = NO;
		
		[self addLabelWithFrame:CGRectMake(8, 8, 128, 11) text:@""];
    }
    return self;
}

- (void)dealloc 
{
    [label release];
	[_delegate release];
    [super dealloc];
}

- (void) addLabelWithFrame:(CGRect)rect text:(NSString*)labelText
{
	UILabel *aLabel = [[UILabel alloc] initWithFrame:rect];
	[aLabel setFont:MD_FONT];
	[aLabel setTextColor:[UIColor whiteColor]];
	[aLabel setBackgroundColor:[self backgroundColor]];
	[aLabel setText:labelText];
	[self addSubview:aLabel];
	
	// save if first label
	if( !label )
	{
		label = aLabel;
	}
	else
	{
		[aLabel release];
	}
}

- (void) setLabelText:(NSString*)labelText
{
	[label setText:labelText];
}

- (float) toControl:(float)x
{
	if( reverse ) x = 1 - x;
	
	if( taper == audio )
		x = lin2log(x);
	else if( taper == reverseAudio )
		x = lin2exp(x);
	
	return x;
}

- (float) fromControl:(float)x
{
	if( taper == audio ) 
		x = lin2exp(x);
	else if( taper == reverseAudio ) 
		x = lin2log(x);
	
	if( reverse ) x = 1 - x;
	
	return x;
}

- (void) refresh
{
	// override me
}

@end
