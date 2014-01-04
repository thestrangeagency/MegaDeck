//
//  SliceView.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 5/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "SliceView.h"
#import "SliceLoopView.h"

@implementation SliceView

@synthesize sliceID, activeHeight, mutedHeight, isMuted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        originalFrame = frame;
        highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        highlightView.backgroundColor = self.backgroundColor;
        highlightView.alpha = 1;
        highlightView.userInteractionEnabled = NO;
        [self addSubview:highlightView];
    }
    return self;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"sliceID: %i, isMuted: %@", sliceID, [NSNumber numberWithBool:isMuted]];
    return desc;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    highlightView.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setIsMuted:(BOOL)_isMuted
{
    isMuted = _isMuted;
    
    if (isMuted)
    {
        highlightView.hidden = YES;
    }
    else 
    {
        highlightView.hidden = NO;
    }
}

- (void)trigger
{    
	[UIView animateWithDuration:.1 
						  delay:0 
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 highlightView.frame = CGRectMake((self.frame.size.width - activeHeight) / 2, (self.frame.size.height - activeHeight) / 2, activeHeight, activeHeight);
					 } 
					 completion:^(BOOL finished) {
						 // shrink
						 [UIView animateWithDuration:.1 
										  animations:^{
											  highlightView.frame = CGRectMake(0, 0, originalFrame.size.width, originalFrame.size.height);
										  }];
					 }
	 ];
	
	SliceLoopView *loopView = (SliceLoopView *)self.superview;
	[loopView moveSliceToActivePosition:self];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();    
    CGContextBeginPath(ctx);
	
	CGContextAddRect(ctx, rect);
    CGContextClosePath(ctx);

    CGContextSetRGBFillColor(ctx, 0.05, 0.05, 0.05, 1);
    CGContextFillPath(ctx);
    CGContextStrokePath(ctx);
    
    // many diagonals
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:.25 alpha:1.f].CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    int numLines = 5; // odd number is best
    int padding = 5;
    int numSpaces = ((numLines + 1) / 2); // num of spaces the horizontal or vertical axis is divided into
    float spacing = (rect.size.width - padding * 2) / numSpaces; // length of each space
    
    for (int i = 0; i < numLines; i++)
    {
        float startX;
        float startY;
        float endX;
        float endY;
        
        if (i < numLines / 2.0)
        {
            startX = padding;
            startY = padding + i * spacing;
            
            endX = padding + (numSpaces - i) * spacing;
            endY = rect.size.width - padding;
        }
        else 
        {
            startX = padding + (i - floor(numLines / 2)) * spacing;
            startY = padding;
            
            endX = rect.size.width - padding;
            endY = padding + (numLines - i) * spacing;
        }
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, startX, startY);
        CGContextAddLineToPoint(ctx, endX, endY);
        CGContextStrokePath(ctx);
    }
}

@end
