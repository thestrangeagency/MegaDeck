/**
 * a view that can be moved
 * stripped down SINGLE TOUCH version
 */

#import <UIKit/UIKit.h>
#import "InteractiveImageDelegate.h"

#define doubleClickDelay	.1

@interface InteractiveImage : UIView
{	
	NSTimer *timer;
	CGPoint initialTouchLocation;

	BOOL isFirstTouch;
	BOOL isSelected;
	BOOL isEnabled;
	BOOL isDragging;
	
	id<InteractiveImageDelegate> delegate;
}

@property (retain) id delegate;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isDragging;

- (void) handleTouches:(NSSet *)allTouches;
- (void) clearTouches;

- (void) onHoldTouch:(NSTimer *)theTimer;
- (void) onSingleTap;
- (void) onDoubleTap;

@end