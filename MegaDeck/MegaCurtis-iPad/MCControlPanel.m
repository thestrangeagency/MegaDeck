//
//  MCControlPanel.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/20/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MCControlPanel.h"
#import "MDInverseButton.h"

#define B_S		40

@interface MCControlPanel ()

- (void) drawButtons;

@end

@implementation MCControlPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"MCControlPanel" ofType:@"plist"];
		panels = [[NSArray alloc] initWithContentsOfFile:path];
		
		[self setBackgroundColor:[UIColor blackColor]];
		[self drawButtons];
    }
    return self;
}

- (void) drawButtons
{
	float y = 0;
	
	for (NSDictionary *dict in panels)
	{
		NSLog(@"panel %@", [dict objectForKey:@"name"]);
		
		MDInverseButton *button = [MDInverseButton buttonWithType:UIButtonTypeCustom];
		
		[button setFrame:CGRectMake(328, y, B_S, B_S)];
		[button setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(notANumber) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:button];
		
		y += B_S;
	}
}


@end
