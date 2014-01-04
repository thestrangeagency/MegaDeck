//
//  MDPasteBoardViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/20/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import "MDPasteBoardViewController.h"
#import "TSADocumentsViewController.h"

#import <UIKit/UIPasteboard.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>

// C-function for appending metadata information to a string
static void AddInfoToString(const void *_key, const void *_value, void *_context) {
	NSMutableString* fmt = (NSMutableString *) _context;
	NSString* key = (NSString *) _key;
	NSString* val = (NSString *) _value;
	
	[fmt appendFormat:@"\n%@: %@", key, val];
}

@implementation MDPasteBoardViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - TSADocumentsViewControllerDelegate

-(void)docsView:(TSADocumentsViewController*)theDocsView didSelectPath:(NSString*)path
{
	if( [theDocsView browserMode] == SAVE_MODE ) 
		[self tryPasteTo:path];
	else 
		[self copyFromPath:path];
}

-(void)docsViewDidCancel:(TSADocumentsViewController*)docsView
{
	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - document control

- (void) showDocsViewInMode:(int)mode
{
	if( !docsView )
	{
		docsView = [[TSADocumentsViewController alloc] init];
		[docsView setDelegate:self];
		[docsView.view setFrame:CGRectMake(192, 160, 320, 480)];
		[self.view addSubview:docsView.view];
		
		CALayer *layer = docsView.view.layer;
		layer.borderWidth = 2;
		layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
		layer.cornerRadius = 10;
		layer.masksToBounds = YES;
	}
	
	[docsView setBrowserMode:mode];
	[docsView reload];
}

- (void) showPasteDialog
{
	[self showDocsViewInMode:SAVE_MODE];
}

- (void) showCopyDialog
{
	[self showDocsViewInMode:LOAD_MODE];
}

- (void) showAlert: (NSString *) message 
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Pasteboard" 
													message:message 
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) showOverwriteWarning:(NSString*)fileName
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
													message:[NSString stringWithFormat:@"Are you sure you want to overwrite %@?",fileName]
												   delegate:self
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"OK",nil];
	[alert show];
	[alert release];
}

- (void) alertView:(UIAlertView*)alert clickedButtonAtIndex:(NSInteger)index
{
	if( index == 0 )
	{
		// cancel
		return;
	}
	else if( index == 1 )
	{
		// OK
		[self pasteToPath:pastePath];
	}
}

#pragma mark -
#pragma mark Copying to clipboard

- (void) copyFromPath:(NSString *)path
{	
	// Open file as binary data
	NSData *data = [NSData dataWithContentsOfMappedFile:path];
	if (!data) 
	{
		[self showAlert:@"copyFromPath: Can't open file"];
		return;
	}
	
	[self copyFromData:data];
}

- (void) copyFromData:(NSData*)data
{
	// Create chunked data and append to clipboard
	NSUInteger sz = [data length];
	NSUInteger chunkNumbers = (sz / BM_CLIPBOARD_CHUNK_SIZE) + 1;
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:chunkNumbers];
	NSRange curRange;
	
	for (NSUInteger i = 0; i < chunkNumbers; i++) {
		curRange.location = i * BM_CLIPBOARD_CHUNK_SIZE;
		curRange.length = MIN(BM_CLIPBOARD_CHUNK_SIZE, sz - curRange.location);
		NSData *subData = [data subdataWithRange:curRange];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:subData forKey:(NSString *)kUTTypeAudio];
		[items addObject:dict];
	}
	
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	board.items = items;
	[self showAlert:@"File copied"];
}

#pragma mark -
#pragma mark Pasting from clipboard

- (void) pasteToData:(NSMutableData*)data
{
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	
	NSArray *typeArray = [NSArray arrayWithObject:(NSString *) kUTTypeAudio];
	NSIndexSet *set = [board itemSetWithPasteboardTypes:typeArray];
	if (!set) {
		[self showAlert:@"Nothing to paste"];
		return;
	}
	
	// Get the subset of kUTTypeAudio elements, and write each chunk to a temporary file
	NSArray *items = [board dataForPasteboardType:(NSString *) kUTTypeAudio inItemSet:set];		
	if (items) {
		UInt32 cnt = [items count];
		if (!cnt) {
			[self showAlert:@"Nothing to paste"];
			return;
		}
		
		// Write each chunk to data
		for (UInt32 i = 0; i < cnt; i++) 
		{
			[data appendData:[items objectAtIndex:i]];
		}
	}
}

- (void) tryPasteTo:(NSString *)path;
{
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
	{
		[pastePath release];
		pastePath = path;
		[pastePath retain];
		[self showOverwriteWarning:[[path componentsSeparatedByString:@"/"] lastObject]];
	}
	else
	{
		[self pasteToPath:path];
	}
}

- (void) pasteToPath:(NSString *)path;
{
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	
	NSArray *typeArray = [NSArray arrayWithObject:(NSString *) kUTTypeAudio];
	NSIndexSet *set = [board itemSetWithPasteboardTypes:typeArray];
	if (!set) {
		[self showAlert:@"Nothing to paste"];
		return;
	}
	
	// Get the subset of kUTTypeAudio elements, and write each chunk to a temporary file
	NSArray *items = [board dataForPasteboardType:(NSString *) kUTTypeAudio inItemSet:set];		
	if (items) {
		UInt32 cnt = [items count];
		if (!cnt) {
			[self showAlert:@"Nothing to paste"];
			return;
		}
		
		// Create a file and write each chunks to it.
		// NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithString:@"temp-pasteboard"]];
		if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
			[self showAlert:@"Can't create file"];
		}
		
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
		if (!handle) {
			[self showAlert:@"Can't open file for writing"];
			return;
		}
		
		// Write each chunk to file
		for (UInt32 i = 0; i < cnt; i++) {
			[handle writeData:[items objectAtIndex:i]];
		}
		[handle closeFile];
		
		//! Quick checks for pasted file recognition
		AudioFileID audioFile = [self openAudioFile:path withWriteAccess:FALSE];
		if (audioFile != nil) {
			[self displayAudioInfo: audioFile];
			[self closeAudioFile: audioFile];
		}
		
		[docsView reload];
	}
}

#pragma mark -
#pragma mark Audio files metadata manipulation 

//! Open an AudioFileID from a file path, display error if any
- (AudioFileID) openAudioFile: (NSString *) path withWriteAccess: (BOOL) writeAccess {
	// Create a NSURL based on a local file
	NSURL *handle = [NSURL fileURLWithPath:path];
	if (handle == nil) {
		[self showAlert:@"NSURL fileURLWithPath failed"];
		return nil;
	}
	
	// Get a new AudioFileID
	AudioFileID audioFileID;
	SInt8 perms = writeAccess ? kAudioFileReadWritePermission : kAudioFileReadPermission;
	OSStatus err = AudioFileOpenURL((CFURLRef) handle, perms, 0, &audioFileID);
	if (err != noErr) {
		[self showAlert:@"AudioFileOpenURL failed"];
		return nil;
	}
	
	return audioFileID;
}

//! Close an AudioFileID
- (void) closeAudioFile: (AudioFileID) audioFileID {
	AudioFileClose(audioFileID);
}

//! Display all the basic information available from an AudioFileID
- (void) displayAudioInfo: (AudioFileID) audioFileID {
	// Get file format
	AudioFileTypeID typeID;
	UInt32 size = sizeof (AudioFileTypeID);
	OSStatus err = AudioFileGetProperty(audioFileID, kAudioFilePropertyFileFormat, &size, &typeID);
	if (err != noErr) {
		[self showAlert:@"AudioFileGetProperty failed"];
		return;
	}
	
	// Get ASBD
	AudioStreamBasicDescription ASBD;
	size = sizeof (AudioStreamBasicDescription);
	err = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &ASBD);
	if (err != noErr) {
		[self showAlert:@"AudioFileGetProperty failed"];
		return;
	}
	
	// Format basic information
	NSMutableString* fmt = [[NSMutableString alloc] init];
	switch (typeID) {
		case kAudioFileAIFFType: {
			[fmt appendFormat:@"Type: AIFF\nSampling Rate: %.2f\nChannels: %lu", (float) ASBD.mSampleRate, ASBD.mChannelsPerFrame];											 
		} break;
			
		case kAudioFileWAVEType: {
			[fmt appendFormat:@"Type: WAVE\nSampling Rate: %.2f\nChannels: %lu", (float) ASBD.mSampleRate, ASBD.mChannelsPerFrame];											 
		} break;
			
		default: {
			[fmt release];
			[self showAlert:@"Not a WAVE of AIFF file"];
			return;
		} break;
	}
	
	// Get Name, BPM, ...
	err = AudioFileGetPropertyInfo(audioFileID, kAudioFilePropertyInfoDictionary, &size, NULL);
	if (err != noErr) {
		[self showAlert:@"AudioFileGetPropertyInfo failed"];
		[fmt release];
		return;
	}
	CFMutableDictionaryRef infoDict = NULL;
	err = AudioFileGetProperty(audioFileID, kAudioFilePropertyInfoDictionary, &size, &infoDict);
	if (err != noErr) {
		[self showAlert:@"AudioFileGetProperty failed"];
		[fmt release];
		return;
	}
	CFDictionaryApplyFunction(infoDict, AddInfoToString, fmt);
	
	// Show info
	[self showAlert: fmt];	
	[fmt release];
	CFRelease(infoDict);
}

@end
