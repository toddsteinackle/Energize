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
#import "Cube.h"
#import "SpikeMine.h"
#import "Explosion.h"
#import "Guardian.h"
#import "Fireball.h"
#import "Ship.h"

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
        cube = [[Cube alloc] initWithPixelLocation:CGPointMake(100.0f, 600.0f)];
        spikeMine = [[SpikeMine alloc] initWithPixelLocation:CGPointMake(200.0f, 600.0f)];
        explosion = [[Explosion alloc] initWithPixelLocation:CGPointMake(300.0f, 600.0f)];
        guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(400.0f, 600.0f)];
        fireball = [[ Fireball alloc] initWithPixelLocation:CGPointMake(500.0f, 600.0f)];
        ship = [[Ship alloc] initWithPixelLocation:CGPointMake(600.0f, 600.0f)];
    }
    return self;
}

#pragma mark -
#pragma mark update
- (void)updateSceneWithDelta:(float)aDelta {

    [starfield updateWithDelta:aDelta];
    [asteroid updateWithDelta:aDelta];
    [cube updateWithDelta:aDelta];
    [spikeMine updateWithDelta:aDelta];
    [explosion updateWithDelta:aDelta];
    [guardian updateWithDelta:aDelta];
    [fireball updateWithDelta:aDelta];
    [ship updateWithDelta:aDelta];
}

#pragma mark -
#pragma mark render
-(void)renderScene {

    //glClear(GL_COLOR_BUFFER_BIT);
    [starfield renderParticles];
    [asteroid render];
    [cube render];
    [spikeMine render];
    [explosion render];
    [guardian render];
    [fireball render];
    [ship render];
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
