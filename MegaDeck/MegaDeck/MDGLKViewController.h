//
//  MDGLKViewController.h
//  MegaDeck
//
//  Created by Lucas Kuzma on 3/30/12.
//  Copyright (c) 2012 The Strange Agency, LLC. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface MDGLKViewController : GLKViewController
{
	GLuint _vertexArray;
    GLuint _vertexBuffer;
	
	GLKMatrix4		projectionMatrix;
	GLKMatrix4		orthoMatrix;
	GLKMatrix4		modelViewMatrix;
	
	CGPoint			iniLocation;
	GLKQuaternion	quarternion;
	
	CGPoint			filteredDelta;
	BOOL			isTouching;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void) setupGL;
- (void) tearDownGL;
- (void) initArcBall;
- (void) rotateMatrixWithArcBall:(GLKMatrix4 *)matrix;
- (void) rotateQuaternionWithVector:(CGPoint)delta;

@end
