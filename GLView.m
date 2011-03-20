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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield.pex"];
        } else {
            starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield-iphone.pex"];
        }

        guardians = [[NSMutableArray alloc] init];

        ship = [[Ship alloc] initWithPixelLocation:CGPointMake(appDelegate.SCREEN_WIDTH / 2, appDelegate.SCREEN_HEIGHT / 2)];

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
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((appDelegate.SCREEN_WIDTH - appDelegate.GUARDIAN_WIDTH) / 2, appDelegate.GUARDIAN_BOTTOM_BASE)
                                           andRotation:0.0f];
    guardian.dx = appDelegate.GUARDIAN_SPEED_HORIZONTAL;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake((appDelegate.SCREEN_WIDTH - appDelegate.GUARDIAN_WIDTH+180.0) / 2, appDelegate.GUARDIAN_TOP_BASE)
                                           andRotation:180.0f];
    guardian.dx = -appDelegate.GUARDIAN_SPEED_HORIZONTAL;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    // left and right
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE, (appDelegate.SCREEN_HEIGHT - appDelegate.GUARDIAN_WIDTH+270.0) / 2)
                                           andRotation:270.0f];
    guardian.dx = 0;
    guardian.dy = appDelegate.GUARDIAN_SPEED_VERTICAL;
    [guardians addObject:guardian];
    [guardian release];

    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE, (appDelegate.SCREEN_HEIGHT - appDelegate.GUARDIAN_WIDTH+90.0) / 2)
                                           andRotation:90.0f];
    guardian.dx = 0;
    guardian.dy = -appDelegate.GUARDIAN_SPEED_VERTICAL;

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
    switch (sceneState) {
#pragma mark SceneState_TransitionIn
        case SceneState_TransitionIn:
            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            if (numTaps == 2) {
                if (ship.state != EntityState_Transporting) {
                    ship.isThrusting = !ship.isThrusting;
                    if (ship.state == EntityState_Idle) {
                        ship.state = EntityState_Alive;
                    }
                }
            }

            if( numTaps > 2 ) {
                [self.viewController showPauseView];
            }
            break;

        default:
            break;
    }
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)paramSender {

    switch (sceneState) {
#pragma mark SceneState_TransitionIn
        case SceneState_TransitionIn:
            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            if (ship.state != EntityState_Transporting) {
                if (ship.state == EntityState_Idle) {
                    ship.state = EntityState_Alive;
                }
            }

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
            break;

        default:
            break;
    }


}

@end
