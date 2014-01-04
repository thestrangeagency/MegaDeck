//
//  MDKeyView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/24/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDKeyView.h"
#import "MDAppDelegate.h"
#import "MathUtil.h"

// some defaults
#define N_KEYS		22
#define N_LINES		13

#define KEY_MASK	0b010100101010

@interface MDKeyView ()

- (void) updateSizes;

@end
	
// ----------------------------------------------------------------------------------------------------

@implementation MDKeyView

@synthesize delegate, isPrettyChromatic, isPortrait, keyAlpha;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self setMultipleTouchEnabled:YES];
		touchDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 5, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		isPrettyChromatic = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyChanged) name:MD_KEY_CHANGE object:nil];
		
		nKeys = N_KEYS;
		nLines = N_LINES;
		keyAlpha = 1.f;
		
#if TARGET_NAME == MegaCurtis_iPad
		isPortrait = NO;
#else
		isPortrait = YES;
#endif
		
		[self updateSizes];
		[self keyChanged];
    }
    return self;
}

- (void) dealloc 
{
	CFRelease(touchDictionary);
	[delegate release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL) isPretty
{
	return isPortrait && [[[MDKeyModel sharedMDKeyModel] scale] isEqualToString:@"chromatic" ] && isPrettyChromatic && ![[MDKeyModel sharedMDKeyModel] fatKeys];
}

- (void) updateSizes
{
	if( isPortrait )
	{
		keyWidth = self.bounds.size.width;
		whiteWidth = keyWidth * (1/3.f);
		blackWidth = keyWidth * (2/3.f);
		keyHeight = self.bounds.size.height / nKeys;
		lineHeight = self.bounds.size.height / nLines;
	}
	else
	{
		keyWidth = self.bounds.size.width / nKeys;
		keyHeight = self.bounds.size.height;
	}
}

- (void) setIsPortrait:(BOOL)_isPortrait
{
	isPortrait = _isPortrait;
	[self updateSizes];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	if( [self isPretty] )
	{
		// draw pretty keyboard
		
		// white key bottoms
		CGRect whiteRect = CGRectMake(0, 0, whiteWidth, self.frame.size.height);	
		CGContextSetGrayFillColor(context, 1.f, keyAlpha);
		CGContextFillRect(context, whiteRect);
		
		// black and white keys
		CGRect keyRect = CGRectMake(whiteWidth, -1, keyWidth-whiteWidth, keyHeight);
		for( int i = 0; i < nKeys; i++ )
		{
			float gray = ~KEY_MASK & 1 << (11 - (i % 12));
			CGContextSetGrayFillColor(context, gray, keyAlpha);
			CGContextFillRect(context, keyRect);
			CGContextTranslateCTM(context , 0, keyHeight);
		}
		
		// reset
		CGContextTranslateCTM(context , 0, -keyHeight*nKeys);
		CGContextSetGrayFillColor(context, 0.f, keyAlpha);
		
		// hairlines
		CGRect lineRect = CGRectMake(0, 0, keyWidth, 1.f); 
		for( int i = 1; i < nLines; i++ )
		{
			// sheer elegance
			if( i == 3 )
				lineRect.origin.y = 5 * keyHeight;
			else if( i == 7 )
				lineRect.origin.y = 12 * keyHeight;
			else if( i == 10 )
				lineRect.origin.y = 17 * keyHeight;
			else
				lineRect.origin.y = round(i * lineHeight);
			
			lineRect.origin.y -= 1;
			CGContextFillRect(context, lineRect);	
		}
	}
	else
	{
		// draw simple keyboard
		
		CGRect keyRect = CGRectMake(0, 0, keyWidth, keyHeight);
		CGRect lineRect = isPortrait ? CGRectMake(0, keyHeight-1, keyWidth, 1.f) : CGRectMake(keyWidth-1, 0, 1.f, keyHeight);
		
		for( int i = 0; i < nKeys; i++ )
		{
			float gray = [[MDKeyModel sharedMDKeyModel] blackAtIndex:i] ? 0 : 1;
			
			CGContextSetGrayFillColor(context, gray, keyAlpha);
			CGContextFillRect(context, keyRect);
			CGContextSetGrayFillColor(context, !gray, keyAlpha);
			CGContextFillRect(context, lineRect);
			
			if( isPortrait )
				CGContextTranslateCTM(context , 0, keyHeight);
			else
				CGContextTranslateCTM(context , keyWidth, 0);
		}
	}
}

// ---------------------------------------------------------------------------------------------------- MDKeyModel
#pragma mark - MDKeyModel notification

- (void)keyChanged
{
	// adjust size for fat keys
	if( isPortrait )
		keyHeight = (self.bounds.size.height / nKeys) * ( [[MDKeyModel sharedMDKeyModel] fatKeys] ? 2 : 1 );
	else
		keyWidth = (self.bounds.size.width / nKeys) * ( [[MDKeyModel sharedMDKeyModel] fatKeys] ? 2 : 1 );
	
	[self setNeedsDisplay];
}

// ---------------------------------------------------------------------------------------------------- shared touches
#pragma mark - shared touches

+ (MDKeyView*)sharedTouchHandler:(MDKeyView*)_handler
{
    static MDKeyView *handler;
	
    if(_handler != nil) 
	{
        if(handler != nil)
            [handler release];
        handler = [_handler retain];
    }
	
    // if(handler == nil)
    //     handler = @"Initialize the var here if you need to";
	
    return handler;
}

- (void)handleSharedTouches:(NSSet*)touches
{
	// sublass override
}

// ---------------------------------------------------------------------------------------------------- touches
#pragma mark - touches

- (int)noteNumberForTouch:(UITouch*)touch
{
	CGPoint location = [touch locationInView:self];
	float x = location.x;
	float y = location.y;
	int baseOctave = [[MDKeyModel sharedMDKeyModel] baseOctave];
	
	if( [self isPretty] )
	{
		// in chromatic mode, deal with pretty keyboard
		
		if( y > 0 )
			if( location.x > whiteWidth )
				return 12 * baseOctave + (y / keyHeight);
			else
			{
				int i = floorf(y / keyHeight);
				// flatten or sharpen black based on position with respect to white key lines
				if( KEY_MASK & 1 << (11 - (i % 12)) )
					if( lineHeight * roundf(y / lineHeight) < y )
						i++;
					else
						i--;
				return 12 * baseOctave + i;
			}
			else
				return -1;
	}
	else
	{
		// just dealing with rectangles in other scales
		int offset = baseOctave * [[MDKeyModel sharedMDKeyModel] notes];
		return isPortrait ? [[MDKeyModel sharedMDKeyModel] noteNumberAtIndex:offset + floorf(y / keyHeight)] : 
							[[MDKeyModel sharedMDKeyModel] noteNumberAtIndex:offset + floorf(x / keyWidth)];
	}
}

- (float)velocityForTouch:(UITouch*)touch
{
	return isPortrait ? CLAMP([touch locationInView:self].x/self.bounds.size.width, 0, 1) : CLAMP([touch locationInView:self].y/self.bounds.size.height, 0, 1);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	for( UITouch *touch in touches )
	{
		int noteNumber = [self noteNumberForTouch:touch];
		
		if( noteNumber >= 0 )
		{
			[delegate notePressed:noteNumber withVelocity:[self velocityForTouch:touch]];
			CFDictionaryAddValue(touchDictionary, touch, [NSNumber numberWithInt:noteNumber]);
		}
	}
	[[MDKeyView sharedTouchHandler:nil] handleSharedTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	for( UITouch *touch in touches )
	{
		int noteNumber = [self noteNumberForTouch:touch];
		int lastNoteNumber = [(NSNumber *)CFDictionaryGetValue(touchDictionary, touch) intValue];
		float velocity = [self velocityForTouch:touch];
		
		if( lastNoteNumber != noteNumber ) 
		{
			if( lastNoteNumber >= 0 )
			{
				[delegate noteReleased:lastNoteNumber];
			}
			
			if( noteNumber >= 0 )
			{
				[delegate notePressed:noteNumber withVelocity:velocity];
			}
			
			CFDictionarySetValue(touchDictionary, touch, [NSNumber numberWithInt:noteNumber]);
		}
		
		[delegate afterTouch:noteNumber withVelocity:velocity];
	}
	[[MDKeyView sharedTouchHandler:nil] handleSharedTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches )
	{
		int noteNumber = [(NSNumber *)CFDictionaryGetValue(touchDictionary, touch) intValue];
		
		if( noteNumber >= 0 )
		{
			[delegate noteReleased:noteNumber];
		}
		
		CFDictionaryRemoveValue(touchDictionary, touch);
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

@end
