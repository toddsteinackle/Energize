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
@synthesize cubeCount;
@synthesize sceneState;
@synthesize lastTimeInLoop;

#pragma mark -
#pragma mark init
-(GLView*)initWithFrame:(CGRect)frame {

    appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];

    sceneState = SceneState_GameBegin;
    lastTimeInLoop = 0;

    drag_min_x = appDelegate.DRAG_MIN_X;
    drag_min_y = appDelegate.DRAG_MIN_Y;

    if ((self = [super initWithFrame:frame])) {
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield.pex"];
        } else {
            starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield-iphone.pex"];
        }

        guardians = [[NSMutableArray alloc] init];
        cubes = [[NSMutableArray alloc] init];

        currentLevel = 0;
        numberOfLevels = 2;

        [self initGuardians];
    }

    return self;
}

- (void)dealloc {
    [guardians release];
    [cubes release];
    [ship release];
    [super dealloc];
}

- (void)initLevel:(int)level {

    [cubes removeAllObjects];
    [ship release];

    // [row][col]
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}

    char levelArray[][7][9] = {
        {
            // 0
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', ' ', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', ' ', 'c', ' ', 's', ' ', 'c', ' ', 'c'},
            { 'c', ' ', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '}

//            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', 's', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}
        },

        {
            // 1
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },
    };

    cubeCount = 0;
    for (int i = 0; i < 7; ++i) {
        for (int j = 0; j < 9; ++j) {
#ifdef GRID_DEBUG
            NSLog(@"initLevel"); int k = 0;
            NSLog(@"%d: %c", k++, levelArray[level][i][j]);
#endif
            char c = levelArray[level][i][j];
            Cube *cube;
            switch (c) {
                case 's':
                    ship = [[Ship alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x-appDelegate.SHIP_STARTING_X_OFFSET,
                                                                           [appDelegate getGridCoordinates:i:j].y-appDelegate.SHIP_STARTING_Y_OFFSET)];
                    break;

                case 'c':
                    cube = [[Cube alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x,
                                                                           [appDelegate getGridCoordinates:i:j].y)
                                             andAppearingDelay:0.5+RANDOM_0_TO_1()];

                    [cubes addObject:cube];
                    [cube release];
                    ++cubeCount;
                    break;

                default:
                    break;
            }
        }
    }
#ifdef GAMEPLAY_DEBUG
    NSLog(@"starting cubeCount -- %i", cubeCount);
#endif
}

- (void)initGuardians {
    Guardian *guardian;
    // bottom
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE, appDelegate.GUARDIAN_BOTTOM_BASE)
                                           andRotation:0.0f];
    guardian.dx = appDelegate.GUARDIAN_SPEED_HORIZONTAL;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    // top
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE, appDelegate.GUARDIAN_TOP_BASE)
                                           andRotation:180.0f];
    guardian.dx = -appDelegate.GUARDIAN_SPEED_HORIZONTAL;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    // left
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE, appDelegate.GUARDIAN_TOP_BASE)
                                           andRotation:270.0f];
    guardian.dx = 0;
    guardian.dy = appDelegate.GUARDIAN_SPEED_VERTICAL;
    [guardians addObject:guardian];
    [guardian release];

    // right
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE, appDelegate.GUARDIAN_BOTTOM_BASE)
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

#pragma mark SceneState_GameBegin
        case SceneState_GameBegin:

            [starfield updateWithDelta:aDelta];
            if (CACurrentMediaTime() - lastTimeInLoop < 0.5) {
                return;
            }
            if (lastTimeInLoop) {
                sceneState = SceneState_GuardianTransport;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();

            break;

#pragma mark SceneState_GuardianTransport
        case SceneState_GuardianTransport:

            [starfield updateWithDelta:aDelta];
            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 2.25) {
                return;
            }
            if (lastTimeInLoop) {
                [self initLevel:currentLevel++];
                sceneState = SceneState_Running;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();
            break;

#pragma mark SceneState_LevelPauseAndInit
        case SceneState_LevelPauseAndInit:
            [starfield updateWithDelta:aDelta];

            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 1.0) {
                return;
            }
            if (lastTimeInLoop) {
                if (currentLevel == numberOfLevels) {
                    currentLevel = 0;
                }
                [self initLevel:currentLevel++];
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

            for (Cube *c in cubes) {
                [c updateWithDelta:aDelta];
                if (c.state == EntityState_Alive) {
                    [ship checkForCollisionWithCube:c];
                }
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

#pragma mark SceneState_GameBegin
        case SceneState_GameBegin:
            [starfield renderParticles];
            break;

#pragma mark SceneState_GuardianTransport
        case SceneState_GuardianTransport:
            [starfield renderParticles];
            for (Guardian *g in guardians) {
                [g render];
            }
            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_LevelPauseAndInit
        case SceneState_LevelPauseAndInit:
            [starfield renderParticles];
            for (Guardian *g in guardians) {
                [g render];
            }
            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            [starfield renderParticles];
            for (Guardian *g in guardians) {
                [g render];
            }
            for (Cube *c in cubes) {
                [c render];
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
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    switch (sceneState) {
        case SceneState_Running:
            if (ship.state != EntityState_Transporting) {
                if (ship.state == EntityState_Idle) {
                    ship.state = EntityState_Alive;
                }
            }

            UITouch *aTouch = [touches anyObject];
            CGPoint loc = [aTouch locationInView:self];
            CGPoint prevloc = [aTouch previousLocationInView:self];

            CGFloat deltaX = loc.x - prevloc.x;
            CGFloat deltaY = loc.y - prevloc.y;

            CGFloat abs_dx = fabs(deltaX);
            CGFloat abs_dy = fabs(deltaY);

#ifdef INPUT_DEBUG
            NSLog(@"loc.x -- %f prevloc.x -- %f deltaX -- %f", loc.x, prevloc.x, deltaX);
            NSLog(@"loc.y -- %f prevloc.y -- %f deltaY -- %f", loc.y, prevloc.y, deltaY);
#endif

            if (abs_dx > drag_min_x || abs_dy > drag_min_y) {
                if (deltaX > 0 && abs_dx > abs_dy) {
                    ship.direction = ship_right;
                    return;
                }
                if (deltaX < 0 && abs_dx > abs_dy) {
                    ship.direction = ship_left;
                    return;
                }
                if (deltaY < 0 && abs_dy > abs_dx) {
                    ship.direction = ship_up;
                    return;
                }
                if (deltaY > 0 && abs_dy > abs_dx) {
                    ship.direction = ship_down;
                    return;
                }
            }
            break;

        default:
            break;
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch* touch = [touches anyObject];
#ifdef INPUT_DEBUG
    CGPoint loc = [touch locationInView:self];
    NSLog(@"x -- %f y -- %f", loc.x, loc.y);
#endif
    NSUInteger numTaps = [touch tapCount];
    switch (sceneState) {

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

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
