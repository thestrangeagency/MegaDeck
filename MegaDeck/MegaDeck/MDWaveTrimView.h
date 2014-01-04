
//  view for displaying and trimming a sound model

#import "MDWaveCursorView.h"

@interface MDWaveTrimView : MDWaveCursorView
{	
	CGFloat start;
	CGFloat end;
	
	UIView *selection;
	UIView *selectionStart;
	UIView *selectionEnd;
}

// sample window as a fraction of the audio data
- (float) startFraction;
- (float) endFraction;
- (float) lengthFraction;


@end
