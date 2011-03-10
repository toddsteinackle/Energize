//
//  GLView.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "GLView.h"
#import "CubeStormAppDelegate.h"
#import "Image.h"
#import "ImageRenderManager.h"
#import "Animation.h"
#import "BitmapFont.h"
#import "SpriteSheet.h"
#import "PackedSpriteSheet.h"
#import "ParticleEmitter.h"
#import "CubeStormViewController.h"
#import "OpenGLViewController.h"
#import "Globals.h"
#import "Asteroid.h"

@implementation GLView

@synthesize viewController;

#pragma mark -
#pragma mark init
-(GLView*)initWithFrame:(CGRect)frame {

    appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];

    sceneState = SceneState_TransitionIn;

    if ((self = [super initWithFrame:frame])) {
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield.pex"];
        asteroid = [[Asteroid alloc] initWithPixelLocation:CGPointMake(500.0f, 300.0f)];
    }
    return self;
}

#pragma mark -
#pragma mark update
- (void)updateSceneWithDelta:(float)aDelta {

    [starfield updateWithDelta:aDelta];
    [asteroid updateWithDelta:aDelta];
}

#pragma mark -
#pragma mark render
-(void)renderScene {

    //glClear(GL_COLOR_BUFFER_BIT);
    [starfield renderParticles];
    [asteroid render];
    [sharedImageRenderManager renderImages];
}

#pragma mark -
#pragma mark handle input
-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    NSLog(@"x -- %f y -- %f", loc.x, loc.y);
    NSUInteger numTaps = [touch tapCount];
    if( numTaps > 1 ) {
        [self.viewController showPauseView];
    }
}

@end
