//
//  InteractiveImage.m
//  STRIPPED DOWN VERSION
//
//  Created by admin on 4/3/09.
//  Copyright 2009 Machinatus. All rights reserved.
//

#import "InteractiveImage.h"
#import "MathUtil.h"

@implementation InteractiveImage

@synthesize delegate,isEnabled,isSelected,isDragging;

- (id)initWithFrame:(CGRect)frame
{	
    if (self = [super initWithFrame:frame]) 
	{
		[self setBackgroundColor:[UIColor blueColor]];
		
		// basic view init
		self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
		self.opaque = NO;
    }
    return self;
}

-(void)setIsEnabled:(BOOL)shouldEnable
{
	isEnabled = shouldEnable;
	if( isEnabled )
	{
		self.userInteractionEnabled = YES;
	}
	else
	{
		[self setIsSelected:NO];
		self.userInteractionEnabled = NO;
	}
}

- (void) setIsSelected:(BOOL)shouldSelect
{
	BOOL wasSelected = isSelected;
	// first set
	isSelected = shouldSelect;
	// then tell delegate, so it can optionally unset
	if( shouldSelect && !wasSelected ) [delegate imageDidSelect:self];
}

- (void) setIsDragging:(BOOL)shouldDrag
{
	if( shouldDrag && !isDragging && delegate ) [delegate imageDidDrag:self];
	if( !shouldDrag && isDragging && delegate ) [delegate imageDidDrop:self];	
	isDragging = shouldDrag;
}

#pragma mark events

- (void) onHoldTouch:(NSTimer *)theTimer
{
	NSLog(@"InteractiveImage::onHoldTouch");	
}

-(void) onSingleTap
{
	NSLog(@"InteractiveImage::onSingleTap");
	[delegate imageDidTap:self];
}

-(void) onDoubleTap
{
	NSLog(@"InteractiveImage::onDoubleTap");	
}

#pragma mark touch

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//	if( CGRectContainsPoint(imageView.frame, point) ) return YES;
//	else return NO;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self setIsSelected:YES];
	isFirstTouch = YES;
	[self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	isFirstTouch = NO;
	[self setIsDragging:YES];
	if([timer isValid])	[timer invalidate];	
	
	if( [delegate respondsToSelector:@selector(imageMoved:)] )
		[delegate imageMoved:self];
	
	[self handleTouches:touches];
}

- (void)handleTouches:(NSSet *)touches
{		
	if( [touches count] == 1 )
	{
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		CGPoint location = [touch locationInView:self.superview];
		
		if( isFirstTouch )
		{
			if( [touch tapCount] == 1 )
			{
				// Start a timer for 2 seconds if we want to detect holding
				timer = [NSTimer scheduledTimerWithTimeInterval:2 
														 target:self 
													   selector:@selector(onHoldTouch:) 
													   userInfo:nil 
														repeats:NO];
				[timer retain];
				
				// get initial touch location
				initialTouchLocation = [MathUtil subtractPoint:location fromPoint:self.center];				
			}
			else if( [touch tapCount] == 2 )
			{
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
			}
		}
		else
		{
			[self setCenter:[MathUtil addPoint:initialTouchLocation toPoint:location]];
		}			
	}
	else if( [touches count] == 2 )
	{
	}
	
	// refresh tools
	// [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if([timer isValid])	[timer invalidate];	

	if( [touches count] == 1 )
	{
		UITouch *touch = [touches anyObject];
		
		if( [touch tapCount] == 1 )
		{
			// has some dragging happened?
			if( !isDragging )
				[self performSelector:@selector(onSingleTap) withObject:nil afterDelay:doubleClickDelay];
		}
		else if( [touch tapCount] == 2 )
		{
			[self onDoubleTap];
		}
	}
	
	[self clearTouches];
}

- (void)touchesCanceled 
{	
	[self clearTouches];
}

- (void)clearTouches
{	
	[self setIsDragging:NO];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
