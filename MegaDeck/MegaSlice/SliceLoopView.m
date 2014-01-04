//
//  SliceLoopView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceLoopView.h"
#import "MathUtil.h"
#import "SliceView.h"
#import <QuartzCore/QuartzCore.h>

#define	BORDER			32
#define HEIGHT			40
#define ACTIVE_HEIGHT	46
#define LOOP_TOUCH_ON	.1f
#define LOOP_TOUCH_OFF	.0f

@implementation SliceLoopView

@synthesize sliceViews, currentlyDraggedSlice;

- (id)initWithFrame:(CGRect)frame loop:(SliceLoopModel*)model
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        loopModel = model;
		sliceViews = [[NSMutableArray alloc] initWithCapacity:N_SLICES];
		
		float x,y;
		for (int i=0; i<N_SLICES; i++) 
		{
			x = BORDER + (i % N_ROWS) * HEIGHT;
			y = BORDER + (i / N_COLUMNS) * HEIGHT;
			
			SliceView *sliceView = [[SliceView alloc] initWithFrame:CGRectMake(x, y, HEIGHT, HEIGHT)];
			NSLog(@"sliceView: %@", sliceView);
			[sliceViews addObject:sliceView];
			[self addSubview:sliceView];
			
            [sliceView setSliceID:i];
            [sliceView setActiveHeight:ACTIVE_HEIGHT];
            [sliceView setMutedHeight:34];
			[sliceView setDelegate:self];
            [sliceView setBackgroundColor:[UIColor colorWithWhite:.1f+LOOP_TOUCH_ON+i/20.f alpha:1.f]];
		}
        
        loopModel.sliceViews = sliceViews;
		
		[self setBackgroundColor:[UIColor colorWithWhite:LOOP_TOUCH_OFF alpha:1.f]];
        
        // cadisplaylink
        CADisplayLink *displayLink;
        displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLinkUpdate:)] retain];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)setModel:(SliceLoopModel*)model
{
    [model retain];
    [loopModel release];
    loopModel = model;
    
    // if model has sliceviews, use them
    if (model.sliceViews)
    {
        self.sliceViews = model.sliceViews;
    }
    // model doesn't have slice views ie it's the first time this layer has been selected
    else
    {
        // reorder slice array
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sliceID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedViews = [sliceViews sortedArrayUsingDescriptors:sortDescriptors];
        [sliceViews release];
        sliceViews = [[NSMutableArray arrayWithArray:sortedViews] retain];
        [sortDescriptor release];
        
        // set slice views in model
        model.sliceViews = sliceViews;
        
        // unmute all slices
        for (SliceView *slice in model.sliceViews)
        {
            slice.isMuted = NO;
        }        
    }
    
    // move slices to positions
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        int newX = (i % N_ROWS) * HEIGHT + BORDER;
        int newY = floor((i / N_COLUMNS)) * HEIGHT + BORDER;
        [slice.layer removeAllAnimations];
        [model sliceAtIndex:i]->isNew = NO;
        slice.isMuted =  ![model sliceAtIndex:slice.sliceID]->isActive; // set slice view mute state based on SliceStruct active state (active means not muted)
        
        [UIView animateWithDuration:.1
                              delay:0
                            options:0
                         animations:^{
                             [slice setFrame:CGRectMake(newX, newY, HEIGHT, HEIGHT)];
                         }
                         completion:^(BOOL finished) {
                         }
         ];
    }
}

- (void)onDisplayLinkUpdate:(CADisplayLink *)sender
{
    // checks if currently playing loop has changed and if so, tell the relevant slice views
    if (indexPlayingSlice != loopModel.loop.currentPosition)
    {
        indexPlayingSlice = loopModel.loop.currentPosition;		
        [((SliceView *)[sliceViews objectAtIndex:indexPlayingSlice]) trigger];
		[loopModel currentSlice]->isNew = NO;
    }
	// retrigger if needed
	if( [loopModel currentSlice]->isNew == YES )
	{
		[((SliceView *)[sliceViews objectAtIndex:indexPlayingSlice]) trigger];
		[loopModel currentPositionSlice]->isNew = NO;
	}
}

- (void)moveSliceToActivePosition:(SliceView *)slice
{
    [self bringSubviewToFront:slice];
    
    if (currentlyDraggedSlice)
        [self bringSubviewToFront:currentlyDraggedSlice];
}

- (void)resetSlices
{    
    // reorder array
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sliceID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	NSArray *sortedViews = [sliceViews sortedArrayUsingDescriptors:sortDescriptors];
	[sliceViews release];
    sliceViews = [[NSMutableArray arrayWithArray:sortedViews] retain];
    [sortDescriptor release];
    
    // animate slices to position
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        NSLog(@"sliceID: %i", slice.sliceID);
        int newX = (slice.sliceID % N_ROWS) * HEIGHT + BORDER;
        int newY = floor((slice.sliceID / N_COLUMNS)) * HEIGHT + BORDER;
        
        [UIView animateWithDuration:.2 animations:^{
            [slice setFrame:CGRectMake(newX, newY, slice.frame.size.width, slice.frame.size.height)];
        }
                         completion:^ (BOOL finished) {}
         ];
    }
    
    loopModel.sliceViews = sliceViews;
}

- (void)unmuteAll
{
    for (SliceView *slice in sliceViews)
    {
        slice.isMuted = NO;
        [loopModel sliceAtIndex:slice.sliceID]->isActive = !slice.isMuted;
    }
	loopModel.sliceViews = sliceViews;
}

- (void)killTouches
{
    // kill touches on loop view
    [self touchesEnded:[NSSet setWithArray:currentTouches] withEvent:nil];
    
    // kill touches on slice
    if (currentlyDraggedSlice)
    {
        [currentlyDraggedSlice clearTouches];
        [self imageDidDrop:currentlyDraggedSlice];
    }
}

// ----------------------------------------------------------------------- slice delegate
#pragma mark - slice delegate

- (void) imageDidSelect:(InteractiveImage*)newlySelectedImage
{
}

- (void) imageDidDrag:(InteractiveImage*)draggedImage
{
//    NSLog(@"imageDidDrag");
    
    SliceView *slice = (SliceView *)draggedImage;
    self.currentlyDraggedSlice = slice;
    
    // bring slice and loop view to front
	[self bringSubviewToFront:slice];
    [[self superview] bringSubviewToFront:self];
}

- (void) imageMoved:(InteractiveImage*)movedImage
{
//    NSLog(@"imageMoved");
    
    SliceView *movedSlice = (SliceView *)movedImage;
    
    // determine hovered position
    int newColumn = floor((movedSlice.center.x - BORDER) / HEIGHT);
    int newRow = floor((movedSlice.center.y - BORDER) / HEIGHT);
    
    // make sure we aren't outside the grid
    if (newColumn < 0 || newColumn > (N_COLUMNS - 1)) return;
    if (newRow < 0 || newRow > (N_ROWS - 1)) return;
    
    int newPosition = newRow * N_COLUMNS + newColumn;
    
    // return if position hasn't changed
    if (newPosition == [sliceViews indexOfObject:movedSlice]) return;
    
    [sliceViews removeObject:movedSlice];
    [sliceViews insertObject:movedSlice atIndex:newPosition];
    
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        
        // skip slices held by other fingers
        if (slice.isDragging) continue;

        int newX = (i % N_ROWS) * HEIGHT + BORDER;
        int newY = floor((i / N_COLUMNS)) * HEIGHT + BORDER;
        
        [UIView animateWithDuration:.2 animations:^{
            [slice setFrame:CGRectMake(newX, newY, HEIGHT, HEIGHT)];
            }
         ];
    }
    
    loopModel.sliceViews = sliceViews;
}

- (void) imageDidDrop:(InteractiveImage*)droppedImage
{
//    NSLog(@"imageDidDrop: %@", droppedImage);
    
    // move the dropped image only to its position
    
    SliceView *droppedSlice = (SliceView *)droppedImage;
    
    int position = [sliceViews indexOfObject:droppedSlice];
    int newX = (position % N_ROWS) * HEIGHT + BORDER;
    int newY = floor((position / N_COLUMNS)) * HEIGHT + BORDER;
    
    [UIView animateWithDuration:.1 animations:^{ [droppedSlice setFrame:CGRectMake(newX, newY, droppedSlice.frame.size.width, droppedSlice.frame.size.height)]; }];
    
    self.currentlyDraggedSlice = nil;    
}

- (void) imageDidTap:(InteractiveImage*)tappedImage
{
    // activate/deactivate slice
    
    SliceView *targetSlice = (SliceView *)tappedImage;
    targetSlice.isMuted = !targetSlice.isMuted;
    [loopModel sliceAtIndex:targetSlice.sliceID]->isActive = !targetSlice.isMuted;
    loopModel.sliceViews = sliceViews;
}

// ----------------------------------------------------------------------- touches
#pragma mark - touches

- (void)handleTouches:(NSSet *)touches
{
    // make arrays of touched indices
    NSMutableArray *touchedColumnIndexes = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *touchedRowIndexes = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *touchedDiagonalIndexes = [NSMutableArray arrayWithCapacity:0];
    
    // iterate through all touches to figure out which indices are being touched
    for (int i = 0; i < currentTouches.count; i++)
    {
        UITouch *touch = [currentTouches objectAtIndex:i];
        CGPoint location = [touch locationInView:self];
        location.x = CLAMP(location.x, 0, self.bounds.size.height);
        location.y = CLAMP(location.y, 0, self.bounds.size.width);
        
        // left or right border
        if ((location.x < BORDER || location.x > BORDER + N_COLUMNS * HEIGHT) && location.y > BORDER && location.y < BORDER + N_ROWS * HEIGHT)
        {            
            int rowNumber = floor((location.y - BORDER) / HEIGHT);
            for (int j = 0; j < N_COLUMNS; j++)
            {
                [touchedRowIndexes addObject:[NSNumber numberWithInt:j + N_ROWS * rowNumber]];
            }
        }
        // top or bottom border
        else if ((location.y < BORDER || location.y > BORDER + N_ROWS * HEIGHT) && location.x > BORDER && location.x < BORDER + N_COLUMNS * HEIGHT)
        {
            int columnNumber = floor((location.x - BORDER) / HEIGHT);
            for (int j = 0; j < N_ROWS; j++)
            {
                [touchedColumnIndexes addObject:[NSNumber numberWithInt:j * N_COLUMNS + columnNumber]];
            }
        }
        // top left or bottom right diagonal
        else if ((location.x < BORDER && location.y < BORDER) || (location.x > BORDER && location.y > BORDER))
        {
            for (int j = 0; j < N_ROWS; j++)
            {
                [touchedDiagonalIndexes addObject:[NSNumber numberWithInt:j * (N_COLUMNS + 1)]];
            }
        }
        // top right or bottom left diagonal
        else if ((location.x > BORDER + N_COLUMNS * HEIGHT && location.y < BORDER) || (location.x < BORDER && location.y > BORDER + N_ROWS * HEIGHT))
        {
            for (int j = 0; j < N_ROWS; j++)
            {
                [touchedDiagonalIndexes addObject:[NSNumber numberWithInt:j * N_COLUMNS + (N_COLUMNS - 1 - j)]];
            }
        }
        else 
        {
            return;
        }
    }
    
//    NSLog(@"touchedRowIndexes: %@", touchedRowIndexes);
//    NSLog(@"touchedColumnIndexes: %@", touchedColumnIndexes);
//    NSLog(@"touchedDiagonalIndexes: %@", touchedDiagonalIndexes);
    
    // find intersection of row indices and column indices
    NSMutableArray *commonIndexes = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *touchedIndexArrays = [NSMutableArray arrayWithCapacity:0];
    
    if (touchedRowIndexes.count > 0) [touchedIndexArrays addObject:touchedRowIndexes];
    if (touchedColumnIndexes.count > 0) [touchedIndexArrays addObject:touchedColumnIndexes];
    if (touchedDiagonalIndexes.count > 0) [touchedIndexArrays addObject:touchedDiagonalIndexes];
    
    for (int i = 0; i < touchedIndexArrays.count; i++)
    {
        if (i == 0)
        {
            commonIndexes = [touchedIndexArrays objectAtIndex:i];
        }
        else 
        {
            NSMutableArray *tempCommonIndexes = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *touchedIndexes = [touchedIndexArrays objectAtIndex:i];
            for (int j = 0; j < touchedIndexes.count; j++)
            {
                NSNumber *rowIndex = [touchedIndexes objectAtIndex:j];
                BOOL doesIntersect = NO;
                for (int k = 0; k < commonIndexes.count; k++)
                {
                    NSNumber *columnIndex = [commonIndexes objectAtIndex:k];
                    if ([rowIndex intValue] == [columnIndex intValue])
                    {
                        doesIntersect = YES;
                        break;
                    }
                }
                
                if (doesIntersect)
                    [tempCommonIndexes addObject:rowIndex];
            }
            commonIndexes = tempCommonIndexes;
        }
    }
                
    // restore slices before setting currently active ones
    NSMutableArray *sliceActiveStates = [sliceActiveStatesStack lastObject];
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        NSNumber *isActive = [sliceActiveStates objectAtIndex:i];
        slice.isMuted = !isActive.boolValue;
        [loopModel sliceAtIndex:slice.sliceID]->isActive = !slice.isMuted;
    }
    
    // set currently active slices
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        BOOL isSelectedSlice = NO;
        for (int j = 0; j < commonIndexes.count; j++)
        {
            NSNumber *commonIndex = [commonIndexes objectAtIndex:j];
            if (i == [commonIndex intValue])
            {
                isSelectedSlice = YES;
                break;
            }
        }
        
        if (!isSelectedSlice)
        {
            slice.isMuted = YES;
            [loopModel sliceAtIndex:slice.sliceID]->isActive = !slice.isMuted;
        }
    }
    
    // update model
    loopModel.sliceViews = sliceViews;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesEnded: %@", touches);
    
    // if there aren't any touches
    if (currentTouches.count == 0)
    {
        return;
    }
    
    // remove touches from array
    [currentTouches removeObjectsInArray:[touches allObjects]];
    
    // if there are still touches, do nothing
    if (currentTouches.count > 0)
    {
        [self handleTouches:touches];
    }
    // no touches left so restore slices
    else 
    {
        // use last active state array to restore slices
        NSMutableArray *sliceActiveStates = [sliceActiveStatesStack lastObject];
        for (int i = 0; i < N_SLICES; i++)
        {
            SliceView *slice = [sliceViews objectAtIndex:i];
            NSNumber *isActive = [sliceActiveStates objectAtIndex:i];
            slice.isMuted = !isActive.boolValue;
            [loopModel sliceAtIndex:slice.sliceID]->isActive = !slice.isMuted;
        }
        
        [sliceActiveStatesStack removeLastObject];
        
        // update model
        loopModel.sliceViews = sliceViews;
		
		// show no touch
		[self setBackgroundColor:[UIColor colorWithWhite:LOOP_TOUCH_OFF alpha:1.f]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{   
//    NSLog(@"touchesBegan: %@", touches);
    
    // add touch to array
    if (!currentTouches)
        currentTouches = [[NSMutableArray alloc] initWithCapacity:1];
    
    [currentTouches addObjectsFromArray:[touches allObjects]];
    
	// if first touch ie active state stack is empty, save active state of all slices
    if (sliceActiveStatesStack.count == 0)
    {
        NSMutableArray *sliceActiveStates = [NSMutableArray arrayWithCapacity:N_SLICES];
        for (int i = 0; i < N_SLICES; i++)
        {
            SliceView *slice = [sliceViews objectAtIndex:i];
            
            // save active state to array
            [sliceActiveStates addObject:[NSNumber numberWithBool:!slice.isMuted]];
        }
        
        // add active state array to stack
        if (!sliceActiveStatesStack)
            sliceActiveStatesStack = [[NSMutableArray alloc] initWithCapacity:1];
        [sliceActiveStatesStack addObject:sliceActiveStates];        
        
		// show touch
		[self setBackgroundColor:[UIColor colorWithWhite:LOOP_TOUCH_ON alpha:1.f]];
    }
    
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
//    NSLog(@"touchesMoved");
    
    // restore before handling touches
    NSMutableArray *sliceActiveStates = [sliceActiveStatesStack lastObject];
    for (int i = 0; i < N_SLICES; i++)
    {
        SliceView *slice = [sliceViews objectAtIndex:i];
        NSNumber *isActive = [sliceActiveStates objectAtIndex:i];
        slice.isMuted = !isActive.boolValue;
        [loopModel sliceAtIndex:slice.sliceID]->isActive = !slice.isMuted;
    }
    
    [self handleTouches:touches];
}

@end
