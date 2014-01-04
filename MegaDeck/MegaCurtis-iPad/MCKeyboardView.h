//
//  MCKeyboardView.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 8/17/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "TSASynthProtocol.h"
#import "MDKeyView.h"

@interface MCKeyboardView : UIView <MDKeyProtocol>
{
	MDKeyView	*keyView;
	UILabel		*noteLabel;

	id<TSASynthProtocol> delegate;
}

@property (retain) id<TSASynthProtocol> delegate;

@end
