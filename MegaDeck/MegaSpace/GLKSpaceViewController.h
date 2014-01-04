//
//  GLKSpaceViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import "MDGLKViewController.h"
#import "TSAGLTrailCloud.h"
#import "SpaceSynthController.h"

@interface GLKSpaceViewController : MDGLKViewController
{	
	TSAGLTrailCloud	*trail;
	SpaceSynthController *synth;
	BOOL renderTrails;
}
@end
