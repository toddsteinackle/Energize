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
@synthesize trackingTime;
@synthesize beatTimer;

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
        asteroids = [[NSMutableArray alloc] init];

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

        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss"
                                                                       imageFilter:GL_LINEAR];
        statusShip = [pss imageForKey:@"ship-up.png"];
        timerBar = [pss imageForKey:@"timer_bar.png"];
        pauseButton = [pss imageForKey:@"pause_button.png"];

        gameContinuing = FALSE;
        timeToInitTimerDisplay = 1.4;

    }

    return self;
}

- (void)dealloc {
    [guardians release];
    [cubes release];
    [spikeMines release];
    [asteroids release];
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
    [asteroids removeAllObjects];
    [ship release];
    trackingTime = FALSE;
    beatTimer = FALSE;
    initingTimer = TRUE;
    initingTimerTracker = 0;
    timerBonus = FALSE;
    timerBonusScore = 0;
    levelPauseAndInitWait = 1.0;
    lastAsteroidLaunch = CACurrentMediaTime();

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
            { 'c', ' ', 'd', ' ', 's', ' ', 'd', ' ', 'c'},
            { 'c', ' ', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '}

        },

        {
            // 1
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', 'd', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { 'c', 'd', ' ', ' ', 'm', 'c', 'c', 'c', ' '},
            { 'c', 'm', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },

        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'd', 'd', 'd', 'c', 'd', ' '},
            { ' ', ' ', 's', ' ', 'm', ' ', 'c', 'd', ' '},
            { ' ', 'd', ' ', ' ', ' ', ' ', 'c', 'd', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', ' ', ' '}
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
                                             andAppearingDelay:0.5+RANDOM_0_TO_1()
                                                  isDoubleCube:FALSE];

                    [cubes addObject:cube];
                    [cube release];
                    ++cubeCount;
                    break;

                case 'd':
                    cube = [[Cube alloc] initWithPixelLocation:CGPointMake([appDelegate getGridCoordinates:i:j].x,
                                                                           [appDelegate getGridCoordinates:i:j].y)
                                             andAppearingDelay:0.5+RANDOM_0_TO_1()
                                                  isDoubleCube:TRUE];

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
            switch (grid) {
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

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 1.0;
                    asteroidLaunchOdds = 10;
                    maxAsteroids = 2;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:60];
                        [asteroids addObject:asteroid];
                        [asteroid release];
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
    for (Asteroid *a in asteroids) {
        a.state = EntityState_Dead;
    }
}

- (void)launchAsteroid {
    if (CACurrentMediaTime() - lastAsteroidLaunch < asteroidLaunchDelay) {
        return;
    }
    lastAsteroidLaunch = CACurrentMediaTime();
    if (1 == (arc4random() % asteroidLaunchOdds + 1)) {
        for (Asteroid *a in asteroids) {
            if (a.state == EntityState_Idle) {
                [a initLaunchLocationWithSpeed:60];
                a.state = EntityState_Alive;
                return;
            }
        }
    }
}

- (void)updateScore {
    score += currentCubeValue;
}

- (void)updateTimerWithDelta:(float)aDelta {
#ifdef TIMER_DEBUG
    NSLog(@"beatTimer: %i", beatTimer);
#endif
    if (trackingTime) {
        timer -= aDelta;
#ifdef TIMER_DEBUG
        NSLog(@"timer: %f", timer);
#endif
        if (timer < 0) {
#ifdef TIMER_DEBUG
            NSLog(@"Times up.");
#endif
            timer = 0;
            trackingTime = FALSE;
        }
        return;
    }
    if (initingTimer) {
        initingTimerTracker += aDelta;
        if (initingTimerTracker > timeToInitTimerDisplay) {
            initingTimer = FALSE;
            initingTimerTracker = 0;
        }
    }
}

- (void)calculateTimerBonus {
    timerBonusScore = 1000 * timer;
    timerBonus = TRUE;
    levelPauseAndInitWait = 1.5;
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
                score += timerBonusScore;
                timerBonusScore = 0;
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
            [self updateTimerWithDelta:aDelta];
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
            for (Asteroid *a in asteroids) {
                [a updateWithDelta:aDelta];
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
            [self updateTimerWithDelta:aDelta];
            [self launchAsteroid];
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
            for (Asteroid *a in asteroids) {
                [a updateWithDelta:aDelta];
                if (a.state == EntityState_Alive && ship.state != EntityState_Dead) {
                    [ship checkForCollisionWithEntity:a];
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
            [self launchAsteroid];
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
            for (Asteroid *a in asteroids) {
                [a updateWithDelta:aDelta];
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
            if (timerBonus) {
                [statusFont renderStringJustifiedInFrame:CGRectMake(0, appDelegate.SCREEN_HEIGHT/2, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2)
                                           justification:BitmapFontJustification_MiddleCentered
                                                    text:[NSString stringWithFormat:@"Timer Bonus: %i",timerBonusScore]];
                [sharedImageRenderManager renderImages];
            }
            break;

#pragma mark SceneState_Running
#pragma mark SceneState_ShipRespawn
        case SceneState_Running:
        case SceneState_ShipRespawn:
            [starfield renderParticles];
            for (Cube *c in cubes) {
                [c render];
            }
            for (SpikeMine *s in spikeMines) {
                [s render];
            }
            for (Asteroid *a in asteroids) {
                [a render];
            }
            [self updateStatus];
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
            for (Cube *c in cubes) {
                [c render];
            }
            for (SpikeMine *s in spikeMines) {
                [s render];
            }
            for (Asteroid *a in asteroids) {
                [a render];
            }
            [self updateStatus];
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

    [pauseButton renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE, appDelegate.GUARDIAN_TOP_BOUND)
                         scale:Scale2fMake(appDelegate.widthScaleFactor, appDelegate.heightScaleFactor)
                      rotation:0];

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

    if (sceneState != SceneState_GameOver) {
        if (initingTimer) {
            [timerBar renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE+12*appDelegate.widthScaleFactor,
                                                appDelegate.GUARDIAN_BOTTOM_BOUND+8*appDelegate.heightScaleFactor)
                              scale:Scale2fMake(appDelegate.widthScaleFactor, (initingTimerTracker/timeToInitTimerDisplay)*appDelegate.heightScaleFactor)
                           rotation:0];
        } else {
            [timerBar renderAtPoint:CGPointMake(appDelegate.GUARDIAN_RIGHT_BASE+12*appDelegate.widthScaleFactor,
                                                appDelegate.GUARDIAN_BOTTOM_BOUND+8*appDelegate.heightScaleFactor)
                              scale:Scale2fMake(appDelegate.widthScaleFactor, (timer/timeToCompleteGrid)*appDelegate.heightScaleFactor)
                           rotation:0];
        }

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
    CGPoint loc = [touch locationInView:self];
#ifdef INPUT_DEBUG
    NSLog(@"x -- %f y -- %f", loc.x, loc.y);
#endif
    NSUInteger numTaps = [touch tapCount];

    if (sceneState != SceneState_GameBegin && sceneState != SceneState_GuardianTransport) {
        if (CGRectContainsPoint(CGRectMake(appDelegate.GUARDIAN_RIGHT_BASE, 0,
                                           79*appDelegate.widthScaleFactor, 76*appDelegate.heightScaleFactor), loc)) {
            [self.viewController showPauseView];
            return;
        }
    }

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
    initingTimer = TRUE;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
