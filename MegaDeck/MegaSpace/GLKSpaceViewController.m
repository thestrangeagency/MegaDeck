//
//  GLKSpaceViewController.m
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#define POINTS	1024	// 1024
#define TRAILS	20		// 20

#import "GLKSpaceViewController.h"
#import "MegaSpaceAppDelegate.h"
#import "MathUtil.h"

@implementation GLKSpaceViewController

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
   
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	NSLog(@"Projection:   %f : %f = %f",self.view.bounds.size.width, self.view.bounds.size.height, aspect);
    projectionMatrix = GLKMatrix4MakePerspective(2.2, aspect, 0.1f, 200.0f);
		
	trail = [[TSAGLTrailCloud alloc] initWithPoints:POINTS trails:TRAILS];
	[trail setProjectionMatrix:projectionMatrix];

	synth = (SpaceSynthController *)[[MegaSpaceAppDelegate sharedAppDelegate] synth];
	
	//GLKView *view = (GLKView *)self.view;
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
	
	renderTrails = [[NSUserDefaults standardUserDefaults] boolForKey:@"trails_wave_view"];
}

- (void)dealloc 
{
	[synth setRenderBuffer:NULL
					offset:0 
					stride:8
					 count:POINTS 
				  forVoice:0];
	
	[synth setRenderBuffer:NULL 
					offset:1 
					stride:8
					 count:POINTS 
				  forVoice:1];
	
	[synth setRenderBuffer:NULL 
					offset:2 
					stride:8
					 count:POINTS
				  forVoice:2];
	
    [trail release];
    [super dealloc];
}

- (void)update
{	
	modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -70); 
	
	//[self rotateMatrixWithArcBall:&modelViewMatrix];
	
	[self rotateQuaternionWithVector:filteredDelta];
	[self rotateMatrixWithArcBall:&modelViewMatrix];
	
	// brakes
	if( isTouching )
		filteredDelta = [MathUtil slewPoint:filteredDelta toPoint:CGPointZero withRate:.99];
	
	
	[trail setModelMatrix:modelViewMatrix];
	
	if( renderTrails ) [trail step];
			
	[synth setRenderBuffer:(float*)[trail vertexBuffer] 
					offset:0 
					stride:8
					 count:POINTS 
				  forVoice:0];
	
	[synth setRenderBuffer:(float*)[trail vertexBuffer] 
					offset:1 
					stride:2*sizeof(GLKVector4) / sizeof(float)
					 count:POINTS 
				  forVoice:1];
	
	[synth setRenderBuffer:(float*)[trail vertexBuffer] 
					offset:2 
					stride:8
					 count:POINTS
				  forVoice:2];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(0.f, 0.f, 0.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	[trail render];
}

@end
