//
//  MDControl.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 1/7/12.
//  Copyright (c) 2012 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDControl;

@protocol MDControlDelegate <NSObject>

- (void) valueChanged:(MDControl*)control;
- (float) getValue:(MDControl*)control;

@end

enum CURVE
{
	linear,
	audio,
	reverseAudio
};

@interface MDControl : UIView
{
	UILabel *label;
	id<MDControlDelegate> _delegate;
	enum CURVE	taper;
	BOOL		reverse;
}

@property (retain) id<MDControlDelegate> delegate;
@property enum CURVE taper;
@property BOOL reverse;

// set or change text of default label
- (void) setLabelText:(NSString*)labelText;

// add static label
- (void) addLabelWithFrame:(CGRect)rect text:(NSString*)labelText;

- (float) toControl:(float)x;
- (float) fromControl:(float)x;

// force refresh
- (void) refresh;

@end
