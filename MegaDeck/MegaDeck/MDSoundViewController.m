//
//  MDSoundViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/21/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDSoundViewController.h"
#import "MDAppDelegate.h"

@interface MDSoundViewController (Private)

- (void) suspend;
- (void) resume;
- (void) setThroughUI:(BOOL)isThrough;

@end

@implementation MDSoundViewController

@synthesize delegate;

// ----------------------------------------------------------------------- updates
#pragma mark - updates

- (void) updateTrimLabels
{
	CGRect frame = startLabel.frame;
	CGRect trimFrame = CGRectMake(WAVE_TRIM_RECT);
	CGFloat height = trimFrame.size.height;
	CGFloat labelHeight = frame.size.height;
	CGFloat	border = 8;
	
	frame.origin.y = trimFrame.origin.y + MIN( height - (border + 2*labelHeight), MAX(border, height * [waveTrimView startFraction]) );
	[startLabel setFrame:frame];
	[startLabel setText:[soundModel startString]];

	frame.origin.y = trimFrame.origin.y + MAX( frame.origin.y + frame.size.height, MIN(height - (border + labelHeight), height * [waveTrimView endFraction]) );
	[endLabel setFrame:frame];
	[endLabel setText:[soundModel endString]];	
}

- (void) waveViewDidChange
{
	[soundModel setStartFraction:[waveTrimView startFraction]];
	[soundModel setLengthFraction:[waveTrimView lengthFraction]];
	
	[self updateTrimLabels];
}

- (void) updateTime:(NSTimer*)theTimer
{
	UInt32 frames = [recorder framesRecorded];
	int seconds = frames / 44100.f;
	int minutes = floorf( seconds / 60.0f );
	seconds = roundf( seconds % 60 );
	[timeLabel setText:[NSString stringWithFormat:@"%02i:%02i", minutes, seconds]];
}

- (void) soundDidLoad
{	
	NSLog(@"MDSoundViewController noticed a sound was loaded");
	
	if( !waveTrimView )
	{
		waveTrimView = [[MDWaveTrimView alloc] initWithFrame:CGRectMake(WAVE_TRIM_RECT)];
		NSLog(@"waveTrimView %f,%f", waveTrimView.frame.size.width, waveTrimView.frame.size.height);
		[waveTrimView setSoundModel:soundModel];
		[waveTrimView setDelegate:self];
		[self.view addSubview:waveTrimView];
		
		[self.view bringSubviewToFront:nameLabel];
		[self.view bringSubviewToFront:timeLabel];
		[self.view bringSubviewToFront:startLabel];
		[self.view bringSubviewToFront:endLabel];
	}
	else
	{
		[waveTrimView setSoundModel:soundModel];
	}
	
	[nameLabel setText:[[soundModel lastPath] lastPathComponent]];
	[timeLabel setText:[soundModel lengthString]];
	[self updateTrimLabels];
	[waveTrimView setCursorHidden:YES];
	
	[self resume];
	
	if( [recorder isPlaythrough] && ![soundModel readOnly] ) [self setThroughUI:YES];
}

- (float) positionFraction
{
	return [soundPlayer positionFraction];
}

// ----------------------------------------------------------------------- ui modes
#pragma mark - ui modes

/* shift ui to recording and loading/pasting mode */

- (void) suspend
{
	[self stopPlay];
	[playButton setEnabled:NO];
	[recordButton setEnabled:NO];
	[throughButton setEnabled:NO];
	[okButton setEnabled:NO];
	[xferButton setEnabled:NO];
	
	[waveTrimView setHidden:YES];
	[startLabel setHidden:YES];
	[endLabel setHidden:YES];
}

- (void) resume
{
	[playButton setEnabled:YES];
	[recordButton setEnabled:YES];
	[throughButton setEnabled:YES];	
	[okButton setEnabled:YES];
	[xferButton setEnabled:YES];

	[waveTrimView setHidden:NO];
	[startLabel setHidden:NO];
	[endLabel setHidden:NO];
}

- (void) setThroughUI:(BOOL)isThrough
{
	if( isThrough )
	{
		// freeze rest of ui
		[self stopPlay];
		[playButton setEnabled:NO];
		[recordButton setEnabled:NO];
		[xferButton setEnabled:NO];
		[startLabel setHidden:YES];
		[endLabel setHidden:YES];
		[throughButton setSelected:YES];

		// wave view visuals go
		[waveTrimView animate];
		[waveTrimView setIsLive:YES];
		[waveTrimView setUserInteractionEnabled:NO];
		
		// labels
		[nameLabel setText:@"PLAY THROUGH"];
		[timeLabel setText:@""];
	}
	else
	{
		// wave view visuals stop
		[waveTrimView pause:YES];
		[waveTrimView setIsLive:NO];
		[waveTrimView setUserInteractionEnabled:YES];
		
		// unfreeze rest of ui
		[playButton setEnabled:YES];
		[recordButton setEnabled:YES];
		[xferButton setEnabled:YES];
		[startLabel setHidden:NO];
		[endLabel setHidden:NO];
		[throughButton setSelected:NO];
		
		// labels
		[nameLabel setText:@""];
		[timeLabel setText:@""];
	}
}

// ----------------------------------------------------------------------- child view control
#pragma mark - child view control

- (void)showIoView:(UIViewController*)viewController;
{
	ioViewController = viewController;
	[self.view addSubview:ioViewController.view];
}

- (void)hideIoView
{
	[ioViewController.view removeFromSuperview];
	[ioViewController release];
	ioViewController = nil;
}

- (void)showDocsViewWithMode:(int)browserMode
{
	TSADocumentsViewController *docsView = [[TSADocumentsViewController alloc] initWithMode:browserMode];
	[docsView setDelegate:self];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:docsView];
	navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[docsView release];
	
	[self showIoView:navigationController];
}

// ----------------------------------------------------------------------- TSADocumentsViewControllerDelegate
#pragma mark - TSADocumentsViewControllerDelegate

-(void)docsView:(TSADocumentsViewController*)docsView didSelectPath:(NSString*)path
{	
	if( docsView.browserMode == LOAD_MODE )
	{
		[self suspend];
		[soundModel readAudioFileAtPath:path];
		[nameLabel setText:@"LOADING"];
	}
	else
	{
		[soundModel saveBufferToPath:path];
	}
	
	[self hideIoView];
}

-(void)docsViewDidCancel:(TSADocumentsViewController*)docsView
{
	[self hideIoView];
}

// ----------------------------------------------------------------------- actionSheet
#pragma mark - actionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
	NSLog(@"%@ at sheet index: %i", title, buttonIndex);
	
	// @"Copy", @"Paste", @"Load", @"Save", @"Email"
	
	if( [title isEqualToString:@"Copy"] )
	{		
		// write to temp dir
		[soundModel saveBufferToPath:tempCopyPath];

		// copy from temp dir
		MDPasteBoardViewController *pasteBoard = [[MDPasteBoardViewController alloc] initWithNibName:nil bundle:nil];
		[pasteBoard copyFromPath:tempCopyPath];
		[pasteBoard release];
	}
	else if( [title isEqualToString:@"Paste"] )
	{
		MDPasteBoardViewController *pasteBoard = [[MDPasteBoardViewController alloc] initWithNibName:nil bundle:nil];		
		[pasteBoard pasteToPath:tempCopyPath];
		[pasteBoard release];
		[self suspend];
		[soundModel readAudioFileAtPath:tempCopyPath];
		[nameLabel setText:@"PASTING"];
	}
	else if( [title isEqualToString:@"Load"] )
	{
		[self showDocsViewWithMode:LOAD_MODE];
	}
	else if( [title isEqualToString:@"Save"] )
	{
		[self showDocsViewWithMode:SAVE_MODE];
	}
	else if( [title isEqualToString:@"Email"] )
	{
		MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
		[picker setSubject:@"strange sound"];
		[picker addAttachmentData:[NSData dataWithContentsOfFile:[soundModel lastPath]]
						 mimeType:@"audio/wav, audio/x-wav, audio/wave, audio/x-pn-wav"
						 fileName:[[soundModel lastPath] lastPathComponent]];
		[picker setMessageBody:MD_SHARE_MESSAGE isHTML:NO];
		[picker setMailComposeDelegate:self];
		[self presentModalViewController:picker animated:YES];  

	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error 
{
    [self dismissModalViewControllerAnimated:YES];
}

// ----------------------------------------------------------------------- button handlers
#pragma mark - button handlers

- (IBAction) play
{
	[UIView transitionFromView:playButton 
						toView:stopPlayButton 
					  duration:.25 
					   options:UIViewAnimationOptionTransitionFlipFromRight | 
	 UIViewAnimationOptionAllowUserInteraction | 
	 UIViewAnimationOptionBeginFromCurrentState
					completion:nil];
	
	[waveTrimView setCursorHidden:NO];
	[waveTrimView animate];
	[soundPlayer play];
}

- (IBAction) stopPlay 
{
	[UIView transitionFromView:stopPlayButton 
						toView:playButton 
					  duration:.25 
					   options:UIViewAnimationOptionTransitionFlipFromLeft | 
	 UIViewAnimationOptionAllowUserInteraction | 
	 UIViewAnimationOptionBeginFromCurrentState
					completion:nil];
	
	[soundPlayer stop];
	[waveTrimView setCursorHidden:YES];
	[waveTrimView pause:YES];

}

- (IBAction) record
{
	[UIView transitionFromView:recordButton 
						toView:stopRecordButton 
					  duration:.25 
					   options:UIViewAnimationOptionTransitionFlipFromRight | 
	 UIViewAnimationOptionAllowUserInteraction | 
	 UIViewAnimationOptionBeginFromCurrentState
					completion:nil];
	
	[self suspend];
	
	if( [soundModel recordPath] )
		[recorder setDefaultRecordPath:[soundModel recordPath]];
	
	[recorder prepareRecording];
	[recorder startRecording];
	
	[nameLabel setText:@"RECORDING"];
	
	[self updateTime:nil];
	recordingTimer = [[NSTimer 
					   scheduledTimerWithTimeInterval:0.5 
					   target:self 
					   selector:@selector(updateTime:) 
					   userInfo:nil 
					   repeats:YES] 
					  retain];
}

- (IBAction) stopRecord 
{
	[UIView transitionFromView:stopRecordButton 
						toView:recordButton 
					  duration:.25 
					   options:UIViewAnimationOptionTransitionFlipFromLeft | 
	 UIViewAnimationOptionAllowUserInteraction | 
	 UIViewAnimationOptionBeginFromCurrentState
					completion:nil];
	
	[recorder stopRecording];
	[recorder flush];
	[soundModel readAudioFileAtPath:[recorder defaultRecordPath]];
	
	[recordingTimer invalidate];
	[recordingTimer release];
	recordingTimer = nil;
	[self updateTime:nil];
}

- (IBAction) through
{	
	if( ![recorder canPlaythrough] ) return;
	
	if( [recorder isPlaythrough] )
	{
		// stop playthrough
		
		[recorder stopPlaythrough];		
		[self setThroughUI:NO];
	}
	else
	{
		// start playthrough
		
		[recorder startPlaythrough];
		[self setThroughUI:YES];		
		[soundModel setBufferData:recorder.context->throughBuffer 
					   withLength:recorder.context->throughBufferSize
						   format:recorder.context->format];
	}
}

- (IBAction) action
{
	if( ![soundModel readOnly] )
		actionsSheet = [[UIActionSheet alloc] 
						initWithTitle:@"Action" 
						delegate:self 
						cancelButtonTitle:@"Cancel" 
						destructiveButtonTitle:nil 
						otherButtonTitles:@"Load", @"Save", @"Copy", @"Paste", @"Email", nil];
	else
		actionsSheet = [[UIActionSheet alloc] 
						initWithTitle:@"Action" 
						delegate:self 
						cancelButtonTitle:@"Cancel" 
						destructiveButtonTitle:nil 
						otherButtonTitles:@"Save", @"Copy", @"Email", nil];
	
	actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionsSheet showInView:self.view];
	[actionsSheet release];
}

- (IBAction) ok
{
	NSLog(@"done");
	
	[self stopPlay];
	[delegate soundViewController:self didEdit:soundModel];
}

// ----------------------------------------------------------------------- View Controller
#pragma mark - View Controller

- (id) initWithModel:(MDSoundModel*)model player:(MDSoundPlayer*)player
{
	if ((self = [super initWithNibName:@"MDSoundViewController"	bundle:[NSBundle mainBundle]]))
	{
		soundModel = [model retain];
		soundPlayer = player;
		[player setSoundModel:soundModel];
		recorder = [[MDAppDelegate sharedAppDelegate] inputRecorder];
		
		// register for sound file loaded notifications
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(soundDidLoad) 
													 name:FILE_LOADED 
												   object:nil];
		
		// default paths
		tempCopyPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"Pasteboard"] retain];
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	[waveTrimView release];
	[ioViewController release];
	[soundModel release];
	[soundPlayer release];
	[delegate release];
	[tempCopyPath release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[nameLabel release];
	[timeLabel release];
	[startLabel release];
	[endLabel release];
	
	[playButton release];
	[stopPlayButton release];
	[recordButton release];
	[stopRecordButton release];
    [xferButton release];
    [okButton release];
	
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[stopPlayButton removeFromSuperview];
	[stopRecordButton removeFromSuperview];
	
	if( [soundModel readOnly] )
	{
		[recordView removeFromSuperview];
		[throughButton removeFromSuperview];
	}
	
	if( ![soundModel throughOk] )
	{
		[throughButton removeFromSuperview];
	}
	
	[waveTrimView setCursorHidden:YES];

	if( [soundModel isReady] )
	{
		// file already loaded
		[self soundDidLoad];
	}
	else
	{
		// wait for file to load
		[soundModel readLastAudioFile];
	}
}


- (void)viewDidUnload
{
	[waveTrimView release];
	waveTrimView = nil;
	[ioViewController release];
	ioViewController = nil;
	
	[nameLabel release];
	nameLabel = nil;
	[timeLabel release];
	timeLabel = nil;
	[startLabel release];
	startLabel = nil;
	[endLabel release];
	endLabel = nil;
	
	[playButton release];
	playButton = nil;
	[stopPlayButton release];
	stopPlayButton = nil;
	[recordButton release];
	recordButton = nil;
	[stopRecordButton release];
	stopRecordButton = nil;
    [xferButton release];
    xferButton = nil;
    [okButton release];
    okButton = nil;

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

// iOS 6
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
