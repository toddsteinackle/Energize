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
    lastTimeInLoop = 0;

    if ((self = [super initWithFrame:frame])) {
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield.pex"];

        guardians = [[NSMutableArray alloc] init];

        asteroid = [[Asteroid alloc] initWithPixelLocation:CGPointMake(500.0f, 300.0f)];
        cube = [[Cube alloc] initWithPixelLocation:CGPointMake(100.0f, 600.0f)];
        spikeMine = [[SpikeMine alloc] initWithPixelLocation:CGPointMake(200.0f, 600.0f)];
        explosion = [[Explosion alloc] initWithPixelLocation:CGPointMake(300.0f, 600.0f)];
        fireball = [[ Fireball alloc] initWithPixelLocation:CGPointMake(500.0f, 600.0f)];
        ship = [[Ship alloc] initWithPixelLocation:CGPointMake(600.0f, 600.0f)];

        [self initGuardians];
    }

    return self;
}

- (void)initGuardians {
    Guardian *guardian;
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((IPAD_WIDTH - GUARDIAN_WIDTH) / 2, 100.0f)
                                           andRotation:0.0f];

    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((IPAD_WIDTH - GUARDIAN_WIDTH+180) / 2, IPAD_HEIGHT - 100.0f)
                                           andRotation:180.0f];
    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(100.0f, (IPAD_HEIGHT - GUARDIAN_WIDTH+270) / 2)
                                           andRotation:270.0f];
    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(IPAD_WIDTH - 100.0f, (IPAD_HEIGHT - GUARDIAN_WIDTH+90) / 2)
                                           andRotation:90.0f];
    [guardians addObject:guardian];
    [guardian release];
}

#pragma mark -
#pragma mark update
- (void)updateSceneWithDelta:(float)aDelta {

    switch (sceneState) {

#pragma mark SceneState_TransitionIn
        case SceneState_TransitionIn:

            [starfield updateWithDelta:aDelta];
            if (CACurrentMediaTime() - lastTimeInLoop < 0.5) {
                return;
            }
            if (lastTimeInLoop) {
                sceneState = SceneState_EntitiesAppearing;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();

            break;

#pragma mark SceneState_EntitiesAppearing
        case SceneState_EntitiesAppearing:
            [starfield updateWithDelta:aDelta];
            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 5.0) {
                return;
            }
            if (lastTimeInLoop) {
                sceneState = SceneState_Running;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();

            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            [starfield updateWithDelta:aDelta];
            [asteroid updateWithDelta:aDelta];
            [cube updateWithDelta:aDelta];
            [spikeMine updateWithDelta:aDelta];
            [explosion updateWithDelta:aDelta];
            [fireball updateWithDelta:aDelta];
            [ship updateWithDelta:aDelta];
            break;

        default:
            break;
    }

}

#pragma mark -
#pragma mark render
-(void)renderScene {

    switch (sceneState) {

#pragma mark SceneState_TransitionIn
        case SceneState_TransitionIn:
            [starfield renderParticles];
            break;

#pragma mark SceneState_EntitiesAppearing
        case SceneState_EntitiesAppearing:
            [starfield renderParticles];
            for (Guardian *g in guardians) {
                [g render];
            }
            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            [starfield renderParticles];
            [asteroid render];
            [cube render];
            [spikeMine render];
            [explosion render];
            [fireball render];
            [ship render];
            [sharedImageRenderManager renderImages];
            break;

        default:
            break;
    }

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
