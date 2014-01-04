//
//  MDInverseButton.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 2/17/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import "MDInverseButton.h"

#define WHITE_COLOR	 colorWithRed:.31f green:.78f blue:.86f alpha:1.f

@implementation MDInverseButton

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.titleLabel setFont:MD_FONT];
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state
{
	[super setTitle:title forState:state];
	
	[super setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
	[super setTitleColor:[UIColor WHITE_COLOR] forState:UIControlStateNormal];
	[super setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[super setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
	[super setTitleEdgeInsets:UIEdgeInsetsMake(8, 8, 0, 0)];
}

- (void) addLabelText:(NSString*)labelText
{
	if( !auxLabel )
	{
		auxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 24)];
		[auxLabel setFont:MD_FONT];
		[auxLabel setTextColor:[UIColor WHITE_COLOR]];
		[auxLabel setBackgroundColor:[self backgroundColor]];
		[auxLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [auxLabel setNumberOfLines:2];
		[self addSubview:auxLabel];
	}
	[auxLabel setText:labelText];
}

- (void) updateLabel
{
	[auxLabel setBackgroundColor:[self backgroundColor]];
	[auxLabel setTextColor:[self backgroundColor] == [UIColor WHITE_COLOR] ? [UIColor blackColor] : [UIColor WHITE_COLOR]];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self setBackgroundColor:[UIColor WHITE_COLOR]];
	[self updateLabel];
	return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( ![self isSelected] )
		[self setBackgroundColor:[UIColor blackColor]];
	[self updateLabel];
	[super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	if( ![self isSelected] )
		[self setBackgroundColor:[UIColor blackColor]];
	[self updateLabel];
	[super cancelTrackingWithEvent:event];
}

- (void)setSelected:(BOOL)selected
{
	[self setBackgroundColor:selected ? [UIColor WHITE_COLOR] : [UIColor blackColor]];
	[self updateLabel];
	[super setSelected:selected];
}

@end
