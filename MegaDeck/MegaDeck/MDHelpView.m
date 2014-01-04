//
//  MDHelpView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 7/23/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDHelpView.h"

#define MARKER_SIZE		40.f
#define FOOTER_SIZE		64.f

@interface MDHelpView ()

- (void) placeMarkers;
- (void) showTextForKey:(NSString*)key;
- (void) hideText;

@end

@implementation MDHelpView

- (id)initWithPlist:(NSString*)listName
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenRect];
    if (self) 
	{
		[self setOpaque:NO];
		[self setBackgroundColor:[UIColor clearColor]];
		
		screen = [[UIView alloc] initWithFrame:screenRect];
		[screen setOpaque:NO];
		[screen setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:.5f]];
		[screen setAlpha:.5];
		[self addSubview:screen];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:listName ofType:@"plist"];
		helpDictionary = [[NSDictionary dictionaryWithContentsOfFile:path] retain];

		[self placeMarkers];
		
		textView = [[UITextView alloc] initWithFrame:screenRect];
		[textView setFont:MD_FONT_LARGE];
		[textView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:.25f alpha:1.f]];
		[textView setTextColor:[UIColor whiteColor]];
		[textView setOpaque:YES];
		[textView setUserInteractionEnabled:NO];
		
		CGRect footerRect = CGRectMake(0, screenRect.size.height - FOOTER_SIZE, screenRect.size.width, FOOTER_SIZE);
		footerTextView = [[UITextView alloc] initWithFrame:footerRect];
		[footerTextView setFont:MD_FONT];
		[footerTextView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:.25f alpha:1.f]];
		[footerTextView setTextColor:[UIColor whiteColor]];
		footerTextView.text = [helpDictionary valueForKey:@"footer"];
		[textView addSubview:footerTextView];
		
		[self addSubview:textView];
		
		mode = text;
		
		if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasShownHelp"] )
		{
			[self showTextForKey:@"default"];
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasShownHelp"];
		}
		else
		{
			[self hideText];
		}
    }
    return self;
}

- (void)dealloc 
{
    [helpDictionary release];
	[textView release];
	[footerTextView release];
    [super dealloc];
}

// ----------------------------------------------------------------------------------------------------

- (void) placeMarkers
{
	// make a number formatter
	NSLocale *l_en = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setLocale: l_en];
	
	// loop through help dictionary entries
	for(NSString *key in helpDictionary) 
	{
		// find entries with numeric keys
		NSNumber *keyNumber = [f numberFromString:key];
		if( keyNumber == nil ) continue;
		
		// make sure value is a dictionary, then parse it
		id value = [helpDictionary objectForKey:key];
		if( [value isKindOfClass:[NSDictionary class]] )
		{
			// get marker info
			NSDictionary *markerDict = value;
			NSNumber *x = [markerDict objectForKey:@"x"];
			NSNumber *y = [markerDict objectForKey:@"y"];
			
			// place marker
			MDHelpMarker *marker = [[MDHelpMarker alloc] initWithFrame:CGRectMake([x floatValue], [y floatValue], MARKER_SIZE, MARKER_SIZE)];
			[marker setTag:[keyNumber intValue]];
			[marker setHelpView:self];
			[screen addSubview:marker];
			[marker release];
		}
	}
}

- (void) showTextForKey:(NSString*)key
{
	id value = [helpDictionary valueForKey:key];
	if( [value isKindOfClass:[NSString class]] )
	{
		textView.text = value;
	}
	else if( [value isKindOfClass:[NSDictionary class]] )
	{
		NSDictionary *markerDict = value;
		textView.text = [markerDict valueForKey:@"text"];
	}
	
	textView.hidden = NO;
	screen.hidden = YES;
	
	// hide footer for default
	if( [key isEqualToString:@"default"] ) footerTextView.hidden = YES;
	else footerTextView.hidden = NO;
}

- (void) hideText
{
	textView.hidden = YES;
	screen.hidden = NO;
}

// ---------------------------------------------------------------------------------------------------- shake
#pragma mark - shake

- (BOOL)canBecomeFirstResponder 
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"SHAKE HELP!");
	[self removeFromSuperview];
}

// ----------------------------------------------------------------------- marker touches
#pragma mark - marker touches

- (void) touchMarker:(MDHelpMarker*)marker
{
	[self showTextForKey:[NSString stringWithFormat:@"%i", [marker tag]]];
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{	
	//UITouch *touch = [touches anyObject];
	//CGPoint location = [touch locationInView:self];	
	
	if( mode == text )
	{
		[self hideText];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self handleTouches:[event touchesForView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
