//
//  StokeLoopView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/1/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "StokeLoopView.h"
#import "StokeEventView.h"
#import "MathUtil.h"

#define INNER_R		40.f
#define OUTER_R		100.f

static CGPoint center;

@interface StokeLoopView ()

- (StokeEventView *) enqueueNewEvent;
- (void) quantizeEvent:(StokeEventView*)event;
- (void) deselectExcept:(StokeEventView*)event;

@end

@implementation StokeLoopView

@synthesize delegate, loop;

- (id)initWithLoop:(StokeLoop*)_loop
{
	CGRect frame = CGRectMake(48, 256, 224, 224);
	center = CGPointMake(112, 112);
	
    self = [super initWithFrame:frame];
    if (self) 
	{
        loop = _loop;
		[self enqueueNewEvent];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setOpaque:NO];
		
		displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
		[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		
		NSLog(@"loading loop %@", loop);
		
		// loop has events?
		StokeEvent *event = loop.head;
		if( event )
			do
			{
				StokeEventView *eventView = [self enqueueNewEvent];
				[eventView setEvent:event];
				[self quantizeEvent:eventView];
			}
			while ((event = event->next));
    }
    return self;
}

- (void)dealloc 
{
	[displayLink invalidate];
    [loop release];
	[delegate release];
    [super dealloc];
}

- (void) updateDisplay:(CADisplayLink *)sender
{
	for (StokeEventView *eventView in [self subviews])
	{
		if( ![eventView event] ) continue;
		
		[eventView update];
	}
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextClearRect(ctx, rect);

	// only draw circles if fully visible
	
	if( self.alpha == 1.f )
	{
		CGContextSetLineWidth(ctx, 0.5);
		CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
		
		CGContextAddEllipseInRect(ctx, CGRectMake(12, 12, 200, 200));
		CGContextAddEllipseInRect(ctx, CGRectMake(72, 72, 80, 80));
		
		CGContextStrokePath(ctx);
	}
}

- (StokeEventView *) enqueueNewEvent
{
	StokeEventView *event = [[StokeEventView alloc] init];
	[event setDelegate:self];
	[self addSubview:event];
	[event setCenter:center];
	return event;
}

- (void) addEvent:(StokeEventView*)event
{	
	CGPoint cartesian = [MathUtil subtractPoint:center fromPoint:[event center]];
	CGPoint polar = [MathUtil car2pol:cartesian];
		
	// normalize
	polar.x = (polar.x - INNER_R) / (OUTER_R - INNER_R);
	polar.y /= M_PI * 2.f;
	
	if( [event event] )
	{
		// alter existing
		[loop setEvent:[event event] at:polar.y withProbability:polar.x];
	}
	else
	{
		// add new
		[event setEvent:[loop addEventAt:polar.y withProbability:polar.x]];
	}
	[self quantizeEvent:event];
	
	// refresh superview regarding selection
	[delegate imageDidSelect:event];
	
	// refresh event
	[event refresh];
}

- (void) removeEvent:(StokeEventView*)event
{
	if( [event event] )
	{
		[loop removeEvent:[event event]];
		[event setEvent:NULL];
	}
	[event removeFromSuperview];
}

- (int) quantize
{
	return [loop quantize];
}

- (void) setQuantize:(int)steps updateExisting:(BOOL)update
{
	[loop setQuantize:steps];
	
	if( update )
		for (StokeEventView *subview in [self subviews])
		{
			[self quantizeEvent:subview];
		}
}

- (void) quantizeEvent:(StokeEventView*)event
{
	if( [event event] )
	{
		CGPoint polar = CGPointMake([event event]->probability, [event event]->effective);
		
		// denormalize
		polar.x = polar.x * (OUTER_R - INNER_R) + INNER_R;
		polar.y *= M_PI * 2.f;
		
		CGPoint newCenter = [MathUtil pol2car:polar];
		newCenter = [MathUtil addPoint:center toPoint:newCenter];
		NSLog(@"new %f,%f",newCenter.x,newCenter.y);
		[event setCenter:newCenter];
	}
}

- (void) deselectAll
{
	[self deselectExcept:nil];
}

- (void) deselectExcept:(StokeEventView*)event
{
	for (StokeEventView *subview in [self subviews])
	{
		if( subview != event )
			[subview setIsSelected:NO];
	}
}

// ----------------------------------------------------------------------- slice delegate
#pragma mark - slice delegate

- (void) imageDidSelect:(InteractiveImage*)newlySelectedImage
{
	// ignore selection of center event
	float radius = [MathUtil distanceFromPoint:center toPoint:[newlySelectedImage center]];
	if( radius < INNER_R || radius > OUTER_R )
	{
		// force deselect center
		[newlySelectedImage setIsSelected:NO];
	}
	else
	{
		// select
		[self deselectExcept:(StokeEventView*)newlySelectedImage];
		[self bringSubviewToFront:newlySelectedImage];
		[delegate imageDidSelect:newlySelectedImage];
	}
}

- (void) imageDidDrag:(InteractiveImage*)draggedImage
{
	
}

- (void) imageMoved:(InteractiveImage*)movedImage;
{
	float radius = [MathUtil distanceFromPoint:center toPoint:[movedImage center]];
	if( radius < INNER_R || radius > OUTER_R )
		[movedImage setAlpha:.4];
	else
		[movedImage setAlpha:1];
}

- (void) imageDidDrop:(StokeEventView*)droppedImage
{
	float radius = [MathUtil distanceFromPoint:center toPoint:[droppedImage center]];
	if( radius < INNER_R || radius > OUTER_R )
	{
		[self removeEvent:droppedImage];
	}
	else
	{
		[self addEvent:droppedImage];
		// select new event
		[self deselectExcept:(StokeEventView*)droppedImage];
		[self bringSubviewToFront:droppedImage];
		[droppedImage setIsSelected:YES];
		[delegate imageDidSelect:droppedImage];
	}
	
	[self enqueueNewEvent];
	
	NSLog(@"%@",loop);
}

- (void) imageDidTap:(InteractiveImage*)tappedImage
{
	
}

@end
