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
#import "Constants.h"
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

        ship = [[Ship alloc] initWithPixelLocation:CGPointMake(612.0f, 350.0f)];

        [self initGuardians];
    }

    // Gesture Recognizers
    swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];

    swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipeRightGestureRecognizer];

    swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUpGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipeUpGestureRecognizer];

    swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDownGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipeDownGestureRecognizer];

    return self;
}

- (void)dealloc {
    [guardians release];
    [ship release];
    [swipeLeftGestureRecognizer release];
    [swipeRightGestureRecognizer release];
    [swipeUpGestureRecognizer release];
    [swipeDownGestureRecognizer release];
    [super dealloc];
}

- (void)initGuardians {
    Guardian *guardian;
    // top and bottom
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((IPAD_WIDTH - GUARDIAN_WIDTH) / 2, 100.0f)
                                           andRotation:0.0f];
    guardian.dx = 130.0f;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((IPAD_WIDTH - GUARDIAN_WIDTH+180) / 2, IPAD_HEIGHT - 100.0f)
                                           andRotation:180.0f];
    guardian.dx = -130.0f;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    // right and left
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(100.0f, (IPAD_HEIGHT - GUARDIAN_WIDTH+270) / 2)
                                           andRotation:270.0f];
    guardian.dx = 0;
    guardian.dy = 130.0f;
    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(IPAD_WIDTH - 100.0f, (IPAD_HEIGHT - GUARDIAN_WIDTH+90) / 2)
                                           andRotation:90.0f];
    guardian.dx = 0;
    guardian.dy = -130.0f;

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
                sceneState = SceneState_Running;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();

            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            [starfield updateWithDelta:aDelta];

            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
            }

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

#pragma mark SceneState_Running
        case SceneState_Running:
            [starfield renderParticles];

            for (Guardian *g in guardians) {
                [g render];
            }

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
#ifdef INPUT_DEBUG
    CGPoint loc = [touch locationInView:self];
    NSLog(@"x -- %f y -- %f", loc.x, loc.y);
#endif
    NSUInteger numTaps = [touch tapCount];
    if (numTaps == 2) {
        ship.isThrusting = !ship.isThrusting;
    }
    if( numTaps > 2 ) {
        [self.viewController showPauseView];
    }
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)paramSender {

    switch (paramSender.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            ship.direction = ship_down;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            ship.direction = ship_up;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            ship.direction = ship_left;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            ship.direction = ship_right;
            break;

        default:
            break;
    }

}

@end
