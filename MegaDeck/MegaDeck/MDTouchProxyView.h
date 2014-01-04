//
//  MDTouchProxyView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 4/15/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//
//	simply passes touches to a delegate
//  useful for controlling a view on an external screen

#import <UIKit/UIKit.h>

@interface MDTouchProxyView : UIView

@property (retain) UIResponder *delegate;

@end
