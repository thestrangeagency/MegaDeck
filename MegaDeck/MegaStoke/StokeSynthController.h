//
//  StokeSynthController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 6/4/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "GrainSynthController.h"
#import "StokeLoop.h"

@interface StokeSynthController : GrainSynthController

- (void) setLoop:(StokeLoop*)loop;

@end
