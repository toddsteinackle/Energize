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
@synthesize currentGrid;
@synthesize score;
@synthesize playerLives;

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
        spikeMines = [[NSMutableArray alloc] init];

        currentGrid = 0;
        numberOfGrids = 3;


        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            statusFont = [[BitmapFont alloc] initWithFontImageNamed:@"status.png"
                                                        controlFile:@"status"
                                                              scale:Scale2fMake(1.0f, 1.0f)
                                                             filter:GL_LINEAR];

            largeMessageFont = [[BitmapFont alloc] initWithFontImageNamed:@"largeMessageFont.png"
                                                              controlFile:@"largeMessageFont"
                                                                    scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];

        } else {
            statusFont = [[BitmapFont alloc] initWithFontImageNamed:@"status-iphone.png"
                                                        controlFile:@"status-iphone"
                                                              scale:Scale2fMake(1.0f, 1.0f)
                                                             filter:GL_LINEAR];

            largeMessageFont = [[BitmapFont alloc] initWithFontImageNamed:@"status.png"
                                                              controlFile:@"status"
                                                                    scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
        }
        statusShip = [[Image alloc] initWithImageNamed:@"ship-up.png" filter:GL_LINEAR];
        gameContinuing = FALSE;

    }

    return self;
}

- (void)dealloc {
    [guardians release];
    [cubes release];
    [spikeMines release];
    [ship release];
    [super dealloc];
}

- (void)initGame {

    score = 0;
    currentCubeValue = 50;
    skillLevel = SkillLevel_Normal;
    playerLives = 4;
}

- (void)initGrid:(int)grid {

    [cubes removeAllObjects];
    [spikeMines removeAllObjects];
    [ship release];

    // [row][col]
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
//        { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}

    char gridArray[][7][9] = {
        {
            // 0
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', 'm', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', ' ', 'c', ' ', 's', ' ', 'c', ' ', 'c'},
            { 'c', ' ', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '}

        },

        {
            // 1
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { 'c', ' ', ' ', ' ', 'm', 'c', 'c', 'c', ' '},
            { 'c', 'm', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },

        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', ' ', ' ', ' ', 'c', ' ', ' '},
            { ' ', ' ', 's', ' ', 'm', ' ', 'c', ' ', ' '},
            { ' ', ' ', ' ', ' ', ' ', ' ', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '}
        },
    };

    cubeCount = 0;
    for (int i = 0; i < 7; ++i) {
        for (int j = 0; j < 9; ++j) {
#ifdef GRID_DEBUG
            NSLog(@"initGrid"); int k = 0;
            NSLog(@"%d: %c", k++, gridArray[grid][i][j]);
#endif
            char c = gridArray[grid][i][j];
            Cube *cube;
            SpikeMine *spike;
            switch (c) {
                case 's':
                    ship = [[Ship alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x-appDelegate.SHIP_STARTING_X_OFFSET,
                                                                           [appDelegate getGridCoordinates:i:j].y-appDelegate.SHIP_STARTING_Y_OFFSET)];

                    startingShipPosition = CGPointMake([appDelegate getGridCoordinates:i:j].x-appDelegate.SHIP_STARTING_X_OFFSET,
                                                       [appDelegate getGridCoordinates:i:j].y-appDelegate.SHIP_STARTING_Y_OFFSET);
                    break;

                case 'c':
                    cube = [[Cube alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x,
                                                                           [appDelegate getGridCoordinates:i:j].y)
                                             andAppearingDelay:0.5+RANDOM_0_TO_1()];

                    [cubes addObject:cube];
                    [cube release];
                    ++cubeCount;
                    break;

                case 'm':
                    spike = [[SpikeMine alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x,
                                                                                 [appDelegate getGridCoordinates:i:j].y)
                                                   andAppearingDelay:0.75+RANDOM_0_TO_1()];
                    [spikeMines addObject:spike];
                    [spike release];
                    break;


                default:
                    break;
            }
        }
    }
#ifdef GAMEPLAY_DEBUG
    NSLog(@"starting cubeCount -- %i", cubeCount);
#endif

#pragma mark skill levels
    switch (skillLevel) {
        case SkillLevel_Easy:

            break;

        case SkillLevel_Normal:
            switch (currentGrid) {
                case 0:
                case 1:
                case 2:
                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 7;
                        g.chanceForTwoFireballs = 5;
                        g.chanceForThreeFireballs = 8;
                        g.chanceForFourFireballs = 10;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    break;

                default:
                    break;
            }

            break;

        case SkillLevel_Hard:

            break;

        default:
            break;
    }
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
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE+
                                                                   appDelegate.GUARDIAN_WIDTH-appDelegate.GUARDIAN_LEFT_BASE,
                                                                   appDelegate.GUARDIAN_TOP_BASE)
                                           andRotation:180.0f];
    guardian.dx = -appDelegate.GUARDIAN_SPEED_HORIZONTAL;
    guardian.dy = 0;

    [guardians addObject:guardian];
    [guardian release];

    // left
    guardian = [[Guardian alloc] initWithPixelLocation:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE,
                                                                   appDelegate.GUARDIAN_TOP_BASE+(41*appDelegate.heightScaleFactor)-
                                                                   (15*appDelegate.heightScaleFactor))
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
#pragma mark game play

- (void)resetGuardiansAndClearGrid {
    for (Guardian *g in guardians) {
        g.firingTimer = 0;
        g.canFire = FALSE;
        g.animation.currentFrame = 15;
        g.animation.state = kAnimationState_Stopped;
        for (Fireball *f in g.fireballs) {
            f.state = EntityState_Idle;
        }
    }
    for (SpikeMine *s in spikeMines) {
        s.state = EntityState_Dead;
    }
}

- (void)updateScore {
    score += currentCubeValue;
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
                [guardians removeAllObjects];
                [self initGuardians];
                [self initGame];
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
                [self initGrid:currentGrid++];
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
                if (currentGrid == numberOfGrids) {
                    currentGrid = 0;
                }
                [self initGrid:currentGrid++];
                if (gameContinuing) {
                    gameContinuing = FALSE;
                }
                for (Guardian *g in guardians) {
                    g.canFire = TRUE;
                }
                sceneState = SceneState_Running;
                lastTimeInLoop = 0;
            }
            lastTimeInLoop = CACurrentMediaTime();

            break;

#pragma mark SceneState_ShipRespawn
        case SceneState_ShipRespawn:
            [starfield updateWithDelta:aDelta];
            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
                for (Fireball *f in g.fireballs) {
                    [f updateWithDelta:aDelta];
                }
            }
            for (Cube *c in cubes) {
                [c updateWithDelta:aDelta];
            }
            for (SpikeMine *s in spikeMines) {
                [s updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 1.0) {
                return;
            }
            if (lastTimeInLoop) {
                [ship release];
                ship = [[Ship alloc] initWithPixelLocation:startingShipPosition];
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
                for (Fireball *f in g.fireballs) {
                    [f updateWithDelta:aDelta];
                    if (f.state == EntityState_Alive && ship.state != EntityState_Dead) {
                        [ship checkForCollisionWithEntity:f];
                    }
                }
            }

            for (Cube *c in cubes) {
                [c updateWithDelta:aDelta];
                if (c.state == EntityState_Alive && ship.state != EntityState_Dead) {
                    [ship checkForCollisionWithEntityRenderedCenter:c];
                }
            }
            for (SpikeMine *s in spikeMines) {
                [s updateWithDelta:aDelta];
                if (s.state == EntityState_Alive && ship.state != EntityState_Dead) {
                    [ship checkForCollisionWithEntityRenderedCenter:s];
                }
            }

            [ship updateWithDelta:aDelta];
            if (ship.state == EntityState_Dead &&
                ship.explosion.animation.state == kAnimationState_Stopped) {
                if (playerLives == 0) {
                    sceneState = SceneState_GameOver;
                    lastTimeInLoop = 0;
                    return;
                }
                if (cubeCount == 0) {
                    sceneState = SceneState_LevelPauseAndInit;
                    lastTimeInLoop = 0;
                } else {
                    sceneState = SceneState_ShipRespawn;
                    lastTimeInLoop = 0;
                }
            }

            break;

#pragma mark SceneState_GameOver
        case SceneState_GameOver:
            [starfield updateWithDelta:aDelta];
            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
                for (Fireball *f in g.fireballs) {
                    [f updateWithDelta:aDelta];
                }
            }
            for (Cube *c in cubes) {
                [c updateWithDelta:aDelta];
            }
            for (SpikeMine *s in spikeMines) {
                [s updateWithDelta:aDelta];
            }
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
            [self updateStatus];
            for (Guardian *g in guardians) {
                [g render];
            }
            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_Running
#pragma mark SceneState_ShipRespawn
        case SceneState_Running:
        case SceneState_ShipRespawn:
            [starfield renderParticles];
            [self updateStatus];
            for (Cube *c in cubes) {
                [c render];
            }
            for (SpikeMine *s in spikeMines) {
                [s render];
            }
            for (Guardian *g in guardians) {
                [g render];
                for (Fireball *f in g.fireballs) {
                    [f render];
                }
            }
            [ship render];
            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_GameOver
        case SceneState_GameOver:
            [starfield renderParticles];
            [self updateStatus];
            for (Cube *c in cubes) {
                [c render];
            }
            for (SpikeMine *s in spikeMines) {
            [s render];
            }
            for (Guardian *g in guardians) {
                [g render];
                for (Fireball *f in g.fireballs) {
                    [f render];
                }
            }
            [sharedImageRenderManager renderImages];


            [largeMessageFont renderStringJustifiedInFrame:CGRectMake(0, appDelegate.SCREEN_HEIGHT/2, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2)
                                                 justification:BitmapFontJustification_MiddleCentered text:@"Game Over"];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                             justification:BitmapFontJustification_TopCentered text:@"Tap to play again, starting at current grid."];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                             justification:BitmapFontJustification_MiddleCentered text:@"Double Tap to return to main menu."];

            [sharedImageRenderManager renderImages];
            break;


        default:
            break;
    }

}

- (void)updateStatus {
    if (playerLives > 8) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [statusFont renderStringAt:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE-appDelegate.SHIP_WIDTH*2-3, appDelegate.GUARDIAN_TOP_BASE)
                                  text:[NSString stringWithFormat:@"%i", playerLives]];
            [statusShip renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE-(appDelegate.SHIP_WIDTH+appDelegate.widthScaleFactor*3),
                                                  appDelegate.GUARDIAN_TOP_BASE-appDelegate.heightScaleFactor*5)
                                scale:Scale2fMake(appDelegate.widthScaleFactor, appDelegate.heightScaleFactor)
                             rotation:0];
        } else {
            [statusFont renderStringAt:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE-appDelegate.SHIP_WIDTH*2-5, appDelegate.GUARDIAN_TOP_BASE-2)
                                  text:[NSString stringWithFormat:@"%i", playerLives]];
            [statusShip renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE-(appDelegate.SHIP_WIDTH+appDelegate.widthScaleFactor*3),
                                                  appDelegate.GUARDIAN_TOP_BASE-appDelegate.heightScaleFactor*7)
                                scale:Scale2fMake(appDelegate.widthScaleFactor, appDelegate.heightScaleFactor)
                             rotation:0];
        }
    }
    else {
        for (int i = 1; i < playerLives; ++i) {
            [statusShip renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE-(i*appDelegate.SHIP_WIDTH+appDelegate.widthScaleFactor*3),
                                                  appDelegate.GUARDIAN_TOP_BASE-appDelegate.heightScaleFactor*7)
                                scale:Scale2fMake(appDelegate.widthScaleFactor, appDelegate.heightScaleFactor)
                             rotation:0];
        }
    }

    int gridNumberDisplayed;
    if (gameContinuing) {
        gridNumberDisplayed = currentGrid + 1;
    } else {
        gridNumberDisplayed = currentGrid;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [statusFont renderStringAt:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE+appDelegate.GUARDIAN_WIDTH, appDelegate.GUARDIAN_TOP_BASE)
                              text:[NSString stringWithFormat:@"Grid: %i    Score: %i", gridNumberDisplayed, score]];
    } else {
        [statusFont renderStringAt:CGPointMake(appDelegate.GUARDIAN_LEFT_BASE+appDelegate.GUARDIAN_WIDTH, appDelegate.GUARDIAN_TOP_BASE-2)
                              text:[NSString stringWithFormat:@"Grid: %i    Score: %i", gridNumberDisplayed, score]];
    }
}

#pragma mark -
#pragma mark handle input
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *aTouch = [touches anyObject];
    switch (sceneState) {
        case SceneState_GameOver:
            if (aTouch.tapCount == 2) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
            }
            break;

        default:
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    switch (sceneState) {
#pragma mark SceneState_Running
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
            if (numTaps == 1) {
                if (ship.state == EntityState_Alive) {
                    ship.isThrusting = !ship.isThrusting;
                }
            }
            break;

#pragma mark SceneState_GameOver
        case SceneState_GameOver:
            if (numTaps == 1) {
                NSDictionary *touchLoc = [NSDictionary dictionaryWithObject:[NSValue valueWithCGPoint:[touch locationInView:self]]
                                                                     forKey:@"location"];
                [self performSelector:@selector(handleSingleTap:) withObject:touchLoc afterDelay:0.3];
            } else if (numTaps == 2) {
                sceneState = SceneState_GameBegin;
                currentGrid = 0;
                [self.viewController quitGame];
            }
            break;

        default:
            break;
    }

}

- (void)handleSingleTap:(NSDictionary *)touches {
    [self resetGuardiansAndClearGrid];
    --currentGrid;
    gameContinuing = TRUE;
    [self initGame];
    sceneState = SceneState_LevelPauseAndInit;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
