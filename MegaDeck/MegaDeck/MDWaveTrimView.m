#import "MDWaveTrimView.h"

@implementation MDWaveTrimView

- (void) updateSelection
{
	selection.frame = CGRectMake(0, start, self.frame.size.width, end - start);
	selectionStart.frame = CGRectMake(0, 0, self.frame.size.width, start);
	selectionEnd.frame = CGRectMake(0, end, self.frame.size.width, self.frame.size.height - end);
}

// ----------------------------------------------------------------------- UIView
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame 
{
	self = [super initWithFrame:frame];
    if (self) 
	{		
		selection = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:selection];
		[selection setBackgroundColor:[UIColor blueColor]];
		[selection setHidden:YES];
		[selection setUserInteractionEnabled:NO];

		selectionStart = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:selectionStart];
		[selectionStart setBackgroundColor:[UIColor blackColor]];
		[selectionStart setAlpha:.9];
		[selectionStart setUserInteractionEnabled:NO];
		
		selectionEnd = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:selectionEnd];
		[selectionEnd setBackgroundColor:[UIColor blackColor]];
		[selectionEnd setAlpha:.9];
		[selectionEnd setUserInteractionEnabled:NO];
			
		[self setMultipleTouchEnabled:YES];
		[self reset];
	}
    return self;
}

- (void) dealloc
{
	[selection release];
	[selectionStart release];
	[selectionEnd release];
	
	[super dealloc];
}

// ----------------------------------------------------------------------- touches
#pragma mark touches

- (void)handleTouches:(NSSet *)touches
{
	for( UITouch *touch in touches )
	{
		CGPoint touchLocation = [touch locationInView:self];

		// which selection part is closer?
		if( fabsf(touchLocation.y - start ) < fabsf(touchLocation.y - end ) )
		{
			// occasional negative y bug on phone
			start = MAX(0,touchLocation.y);
		}
		else
		{
			// constrain to bounds
			end = MIN(touchLocation.y, self.bounds.size.height);
		}
	}
	
	[self updateSelection];
	[delegate waveViewDidChange];
}

// ----------------------------------------------------------------------- public
#pragma mark public

-(void) suspend
{
	[selection setHidden:YES];
	[super suspend];
}

-(void) reset
{
	[super reset];
	
	if( soundModel && soundModel.isReady )
	{
		// init selection
		start = self.frame.size.height * soundModel.startFraction;
		end = self.frame.size.height * soundModel.endFraction;
				
		// update views
		[self updateSelection];
	}
	else
	{
		[self suspend];
	}
}

- (float) startFraction;
{
	return start / self.frame.size.height;
}

- (float) endFraction
{
	return end / self.frame.size.height;
}

- (float) lengthFraction
{
	return (end - start) / self.frame.size.height;
}

@end
