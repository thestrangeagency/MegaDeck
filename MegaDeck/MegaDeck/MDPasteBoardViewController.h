//
//  MDPasteBoardViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 12/20/11.
//  Copyright (c) 2011 Machinatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSADocumentsViewController.h"
#import <AudioToolbox/AudioFile.h>

// 5MB max per item in iPhone OS clipboard
#define BM_CLIPBOARD_CHUNK_SIZE (5 * 1024 * 1024)

@interface MDPasteBoardViewController : UIViewController <TSADocumentsViewControllerDelegate,UIAlertViewDelegate> 
{
    TSADocumentsViewController *docsView;
	NSString *pastePath;
}

// use to show file UI
- (void) showPasteDialog;
- (void) showCopyDialog;

// file copy paste
- (void) copyFromPath:(NSString *)path;
- (void) tryPasteTo:(NSString *)path;
- (void) pasteToPath:(NSString *)path;

// data copy paste
- (void) copyFromData:(NSData*)data;
- (void) pasteToData:(NSMutableData*)data;

// intua copy paste extras
- (void) showAlert: (NSString *) message;
- (AudioFileID) openAudioFile: (NSString *) path withWriteAccess: (BOOL) writeAcces;
- (void) closeAudioFile: (AudioFileID) audioFileID;
- (void) displayAudioInfo: (AudioFileID) audioFileID;

@end
