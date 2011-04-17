//
//  GLView.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "GLView.h"
#import "EnergizeAppDelegate.h"
#import "Image.h"
#import "ImageRenderManager.h"
#import "SoundManager.h"
#import "Animation.h"
#import "BitmapFont.h"
#import "SpriteSheet.h"
#import "PackedSpriteSheet.h"
#import "ParticleEmitter.h"
#import "EnergizeViewController.h"
#import "OpenGLViewController.h"
#import "Asteroid.h"
#import "Cube.h"
#import "SpikeMine.h"
#import "Explosion.h"
#import "Guardian.h"
#import "Fireball.h"
#import "Ship.h"
#import "PowerUpFireballs.h"
#import "PowerUpShields.h"
#import "PowerUpTimer.h"

@implementation GLView

@synthesize viewController;
@synthesize cubeCount;
@synthesize sceneState;
@synthesize skillLevel;
@synthesize lastTimeInLoop;
@synthesize currentGrid;
@synthesize score;
@synthesize playerLives;
@synthesize trackingTime;
@synthesize beatTimer;
@synthesize playInitTimerSound;
@synthesize shipThrustingDefault;
@synthesize tapsNeededToToggleThrust;
@synthesize drag_min;
@synthesize randomGridPlayOption;

#pragma mark -
#pragma mark init
-(GLView*)initWithFrame:(CGRect)frame {

    if ((self = [super initWithFrame:frame])) {

        sceneState = SceneState_GameBegin;
        lastTimeInLoop = 0;

        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedSoundManager = [SoundManager sharedSoundManager];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield.pex"];
        } else {
            if (appDelegate.retinaDisplay) {
                starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield-retina.pex"];
            } else {
                starfield = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"starfield-iphone.pex"];
            }
        }

        guardians = [[NSMutableArray alloc] init];
        cubes = [[NSMutableArray alloc] init];
        spikeMines = [[NSMutableArray alloc] init];
        asteroids = [[NSMutableArray alloc] init];
        powerUps = [[NSMutableArray alloc] init];

        currentGrid = 0;
        numberOfGrids = 40;


        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            statusFont = [[BitmapFont alloc] initWithFontImageNamed:@"status.png"
                                                        controlFile:@"status"
                                                              scale:Scale2fMake(1.0f, 1.0f)
                                                             filter:GL_LINEAR];

            largeMessageFont = [[BitmapFont alloc] initWithFontImageNamed:@"largeMessageFont.png"
                                                              controlFile:@"largeMessageFont"
                                                                    scale:Scale2fMake(1.0f, 1.0f)
                                                                   filter:GL_LINEAR];

        } else {

            if (appDelegate.retinaDisplay) {
                statusFont = [[BitmapFont alloc] initWithFontImageNamed:@"status-retina.png"
                                                            controlFile:@"status-retina"
                                                                  scale:Scale2fMake(1.0f, 1.0f)
                                                                 filter:GL_LINEAR];

                largeMessageFont = [[BitmapFont alloc] initWithFontImageNamed:@"largeMessageFont.png"
                                                                  controlFile:@"largeMessageFont"
                                                                        scale:Scale2fMake(1.0f, 1.0f)
                                                                       filter:GL_LINEAR];
            } else {
                statusFont = [[BitmapFont alloc] initWithFontImageNamed:@"status-iphone.png"
                                                            controlFile:@"status-iphone"
                                                                  scale:Scale2fMake(1.0f, 1.0f)
                                                                 filter:GL_LINEAR];

                largeMessageFont = [[BitmapFont alloc] initWithFontImageNamed:@"status.png"
                                                                  controlFile:@"status"
                                                                        scale:Scale2fMake(1.0f, 1.0f)
                                                                       filter:GL_LINEAR];
            }
        }

        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss"
                                                                       imageFilter:GL_LINEAR];
        statusShip = [pss imageForKey:@"ship-up.png"];
        timerBar = [pss imageForKey:@"timer_bar.png"];
        pauseButton = [pss imageForKey:@"pause_button.png"];

        gameContinuing = FALSE;
        timeToInitTimerDisplay = 1.6;


    }

    return self;
}

- (void)loadSounds {
    [sharedSoundManager loadSoundWithKey:@"cube" soundFile:@"Movement3.caf"];
    [sharedSoundManager loadSoundWithKey:@"explosion" soundFile:@"explosion.caf"];
    [sharedSoundManager loadSoundWithKey:@"Impact6b" soundFile:@"Impact6b.caf"];
    [sharedSoundManager loadSoundWithKey:@"guardian_fire" soundFile:@"Boing2.caf"];
    [sharedSoundManager loadSoundWithKey:@"shield_enabled" soundFile:@"ForceField1bLp.caf"];
    [sharedSoundManager loadSoundWithKey:@"fireballs_powerup" soundFile:@"PowerUp2.caf"];
    [sharedSoundManager loadSoundWithKey:@"timer_powerup" soundFile:@"Flourish1b.caf"];
    [sharedSoundManager loadSoundWithKey:@"grid_over" soundFile:@"Win5.caf"];
    [sharedSoundManager loadSoundWithKey:@"game_over" soundFile:@"Negative2.caf"];
    [sharedSoundManager loadSoundWithKey:@"all_grids_completed" soundFile:@"LevelUp1.caf"];
    [sharedSoundManager loadSoundWithKey:@"free_ship" soundFile:@"Flourish5.caf"];
    [sharedSoundManager loadMusicWithKey:@"background_music" musicFile:@"ActionStage05.m4a"];
}
- (void)removeSounds {
    [sharedSoundManager removeSoundWithKey:@"cube"];
    [sharedSoundManager removeSoundWithKey:@"explosion"];
    [sharedSoundManager removeSoundWithKey:@"Impact6b"];
    [sharedSoundManager removeSoundWithKey:@"guardian_fire"];
    [sharedSoundManager removeSoundWithKey:@"shield_enabled"];
    [sharedSoundManager removeSoundWithKey:@"fireballs_powerup"];
    [sharedSoundManager removeSoundWithKey:@"timer_powerup"];
    [sharedSoundManager removeSoundWithKey:@"grid_over"];
    [sharedSoundManager removeSoundWithKey:@"game_over"];
    [sharedSoundManager removeSoundWithKey:@"all_grids_completed"];
    [sharedSoundManager removeSoundWithKey:@"free_ship"];
    [sharedSoundManager removeMusicWithKey:@"background_music"];
}

- (void)dealloc {
    [guardians release];
    [cubes release];
    [spikeMines release];
    [asteroids release];
    [powerUps release];
    [ship release];

    [super dealloc];
}

- (void)initGame {

    score = 0;
    nextFreeShip = freeShipValue = 50000;
    currentCubeValue = 100;
    playerLives = 4;
    timer = 0;
}

- (void)initGrid:(int)grid {

    [cubes removeAllObjects];
    [spikeMines removeAllObjects];
    [asteroids removeAllObjects];
    [powerUps removeAllObjects];
    [ship release];
    trackingTime = FALSE;
    beatTimer = FALSE;
    initingTimer = TRUE;
    playInitTimerSound = TRUE;
    initingTimerTracker = 0;
    timerBonus = FALSE;
    timerBonusScore = 0;
    asteroidTimer = powerUpTimer = 0;
    powerUpTimerReInit = FALSE;

// [row][col]
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
// { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}

    char gridArray[][7][9] = {

        // 1
        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', 'c', ' ', 'c', 'c', 'c', ' ', 'c', ' '},
            { ' ', 'c', ' ', ' ', ' ', ' ', ' ', 'c', ' '},
            { ' ', 'c', ' ', ' ', 's', ' ', 'm', 'c', ' '},
            { ' ', 'c', ' ', ' ', ' ', ' ', ' ', 'c', ' '},
            { ' ', 'c', ' ', 'd', 'd', 'd', ' ', 'c', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '}
        },

        // 2
        {
            { ' ', ' ', ' ', 'c', 'd', 'c', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', ' ', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'd', ' ', 'c', ' ', 's', ' ', 'c', ' ', 'd'},
            { 'c', 'm', 'c', ' ', ' ', ' ', 'c', ' ', 'c'},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', 'c', 'd', 'c', ' ', ' ', ' '}

        },

        // 3
        {
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', 'm', ' ', ' '},
            { ' ', ' ', 'd', 'c', 'c', 'c', 'c', ' ', ' '},
            { 'c', 'c', 'd', ' ', 's', ' ', 'c', 'c', 'd'},
            { ' ', ' ', 'd', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },

        // 4
        {
            { 'c', 'c', 'c', ' ', 'c', 'd', 'd', ' ', ' '},
            { ' ', 'c', 'c', 'c', ' ', 'd', ' ', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'd', ' ', ' ', ' '},
            { ' ', ' ', ' ', 's', ' ', ' ', ' ', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' ', ' '},
            { ' ', ' ', 'm', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' '}
        },

        // 5
        {
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', 'd', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { 'c', 'd', ' ', ' ', 'm', 'c', 'c', 'c', ' '},
            { 'c', 'm', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'd', 'c', 'c', 'c', ' '},
            { ' ', 'c', 'c', 'c', 'd', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },

        // 6
        {
            { 'd', 'c', 'c', ' ', ' ', ' ', 'c', 'c', 'd'},
            { ' ', 'c', 'c', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 's', ' ', ' ', ' '},
            { ' ', 'c', 'c', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'c', 'c', ' ', 'm', ' ', 'c', 'c', ' '},
            { ' ', 'd', ' ', ' ', ' ', ' ', ' ', ' ', 'd'}
        },

        // 7
        {
            { ' ', 'd', 'd', 'd', 'c', ' ', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'm', 'c', 's', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '}
        },

        // 8
        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'm', ' ', ' '},
            { ' ', 'c', 'c', ' ', ' ', 'c', 'c', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', ' ', ' ', ' ', ' '},
            { ' ', ' ', 'c', 'c', ' ', ' ', 's', ' ', ' '},
            { ' ', ' ', 'm', 'd', 'd', 'd', ' ', ' ', ' '},
            { ' ', ' ', 'd', 'd', 'd', ' ', ' ', ' ', ' '}
        },

        // 9
        {
            { 'd', 'c', 'd', 'c', ' ', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', ' ', 's', ' ', ' ', ' '},
            { ' ', 'c', 'c', ' ', 'c', 'c', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'm', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', 'c', 'c', ' ', 'd', 'd', ' ', ' '},
            { ' ', 'c', ' ', 'c', ' ', 'c', 'c', ' ', ' '}
        },

        // 10
        {
            { ' ', 'c', 'c', 'c', 'c', ' ', ' ', ' ', ' '},
            { 'c', ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' '},
            { 'c', ' ', 'd', 'd', ' ', 'c', ' ', ' ', ' '},
            { 'c', ' ', 'd', 'd', ' ', 'c', 's', ' ', ' '},
            { 'c', ' ', 'c', 'c', 'c', 'c', ' ', ' ', ' '},
            { 'c', ' ', ' ', ' ', ' ', ' ', 'c', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'm', 'c', 'c', 'd', 'd'}
        },

        // 11
        {
            { ' ', ' ', ' ', 'm', 'c', 'c', ' ', ' ', ' '},
            { ' ', 'c', ' ', 'c', 'c', 'c', 'c', ' ', ' '},
            { 'c', 'c', 'c', 'c', ' ', 'd', 'd', 'd', 's'},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', 'c', ' ', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'd', 'd', ' ', ' ', ' '}
        },

        // 12
        {
            { ' ', ' ', ' ', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', ' ', 'c', 'c', 'd', 'd'},
            { ' ', 's', ' ', 'c', 'c', 'd', 'd', ' ', ' '},
            { ' ', ' ', 'c', 'c', ' ', 'c', 'c', ' ', ' '},
            { ' ', 'c', 'c', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'c', 'c', 'c', 'm', 'c', 'c', 'c', ' '},
            { ' ', ' ', 'c', 'c', 'd', 'c', 'c', ' ', ' '}
        },

        // 13
        {
            { ' ', ' ', 'c', 'c', ' ', 'c', 'c', ' ', ' '},
            { ' ', 'c', 'c', ' ', 'd', ' ', 'c', 'c', ' '},
            { ' ', 'c', ' ', 'd', 'd', 'd', ' ', 'c', ' '},
            { 'm', 'c', 'c', ' ', 'd', ' ', 'c', 'c', ' '},
            { 'c', ' ', 'c', 'c', 'c', 'c', 'c', ' ', 'c'},
            { 'c', ' ', ' ', ' ', 's', ' ', ' ', ' ', 'c'},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '}
        },

        // 14
        {
            { 'c', 'd', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'd', 'm', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'd'},
            { ' ', ' ', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { 'd', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', ' ', 'd', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'd', 'c'}
        },

        // 15
        {
            { ' ', ' ', ' ', ' ', 'c', 'c', ' ', ' ', ' '},
            { ' ', 'd', 'd', 's', ' ', 'c', 'c', ' ', ' '},
            { ' ', 'd', 'd', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'm', 'c', 'c', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'd', 'd', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'd', 'd', ' ', ' ', 'c', 'c', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'c', 'c', ' ', ' ', ' '}
        },

        // 16
        {
            { ' ', 'c', 'c', ' ', ' ', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'd', 'd', 'd', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', ' ', ' ', 'd', 'd'},
            { 'c', ' ', ' ', ' ', 'c', 'd', 'd', 'd', 'c'},
            { 'c', 's', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { 'm', 'c', 'c', 'c', 'c', 'd', 'd', 'd', 'd'},
            { ' ', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '}
        },

        // 17
        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', 'm', 'c'},
            { ' ', 'd', ' ', ' ', ' ', ' ', ' ', ' ', 'c'},
            { ' ', 'd', 'c', 'c', 'c', ' ', ' ', 'd', ' '},
            { ' ', 'c', ' ', 's', ' ', 'd', 'd', 'd', ' '},
            { ' ', 'c', 'c', 'c', 'c', ' ', 'c', ' ', ' '},
            { 'c', ' ', ' ', ' ', ' ', ' ', 'c', ' ', ' '},
            { 'c', 'm', 'd', 'd', 'd', 'd', 'd', ' ', ' '}
        },

        // 18
        {
            { ' ', ' ', ' ', ' ', 'd', 'd', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', 'c', ' ', 'd', 'd', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', 'c', ' ', ' '},
            { 's', ' ', ' ', 'm', 'd', 'd', ' ', ' ', ' '},
            { ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'd', 'd', ' ', ' ', ' '}
        },

        // 19
        {
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', 'c', 'd', 'd', 'd', 'c', 'd', ' '},
            { ' ', ' ', 's', ' ', 'm', ' ', 'c', 'd', ' '},
            { ' ', 'd', ' ', ' ', ' ', ' ', 'c', 'd', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', ' ', ' '}
        },

        // 20
        {
            { ' ', ' ', ' ', ' ', ' ', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', 's', 'c', 'c', 'c', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', 'm', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', ' ', ' ', 'd', ' '},
            { ' ', 'c', 'c', 'c', ' ', ' ', 'd', 'd', 'd'},
            { 'c', 'c', 'c', ' ', ' ', ' ', 'm', 'd', ' '},
            { 'c', 'c', ' ', ' ', ' ', ' ', ' ', 'd', ' '}
        },

        // 21
        {
            { ' ', 'c', 'c', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'c', ' ', 'c', 'd', 'c', ' ', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '},
            { 'd', 'd', 'd', ' ', 's', ' ', 'd', 'd', 'd'},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', ' ', 'd', ' ', 'c', 'c', 'c'},
            { ' ', 'c', 'm', 'c', ' ', 'c', 'm', 'c', ' '}
        },

        // 22
        {
            { ' ', ' ', 'd', 'd', 'c', 'd', 'd', ' ', ' '},
            { ' ', ' ', ' ', 'c', 's', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', 'd', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', 'c', 'm', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '}
        },

        // 23
        {
            { 'c', 'c', ' ', ' ', ' ', ' ', ' ', 'd', 'd'},
            { ' ', 'c', 'c', 'c', ' ', 'd', 'd', 'd', ' '},
            { ' ', 'd', 'd', 'd', 'm', ' ', ' ', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'd', 'd', 'd', 'd', ' ', ' '},
            { 'c', 'c', 'c', 'c', 's', 'c', 'c', 'c', 'c'},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '}
        },

        // 24
        {
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '},
            { ' ', ' ', 'c', 'c', 'm', 'c', 'c', ' ', ' '},
            { ' ', 'c', 'c', ' ', ' ', ' ', 'c', 'c', ' '},
            { ' ', 'c', 'c', ' ', 'd', ' ', 'c', 'c', ' '},
            { ' ', ' ', 'c', 'c', ' ', 'c', 'c', ' ', 's'},
            { 'd', ' ', ' ', 'c', ' ', 'c', ' ', ' ', 'd'},
            { ' ', 'd', 'd', 'd', 'm', 'd', 'd', 'd', ' '}
        },

        // 25
        {
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', 'd', ' ', ' ', ' ', ' '},
            { ' ', ' ', ' ', 'd', 'c', 'd', ' ', ' ', ' '},
            { ' ', ' ', 'd', 'c', 'm', 'c', 'd', ' ', ' '},
            { ' ', 'd', 'c', ' ', ' ', ' ', 'c', 'd', ' '},
            { 'd', 'c', 'c', 'c', 's', 'c', 'c', 'c', 'd'},
            { 'c', 'c', 'c', 'c', 'm', 'c', 'c', 'c', 'c'}
        },

        // 26
        {
            { ' ', 'c', 'c', 'c', ' ', 'c', 'c', 'c', ' '},
            { 'c', 'd', 'd', ' ', ' ', ' ', 'd', 'd', 'c'},
            { 'c', 'd', ' ', ' ', ' ', ' ', ' ', 'd', 'c'},
            { ' ', 'm', ' ', ' ', 's', ' ', ' ', 'm', ' '},
            { 'c', 'd', ' ', ' ', ' ', ' ', ' ', 'd', 'c'},
            { 'c', 'd', 'd', ' ', ' ', ' ', 'd', 'd', 'c'},
            { ' ', 'c', 'c', 'c', ' ', 'c', 'c', 'c', ' '}
        },

        // 27
        {
            { 'c', 'c', 'c', ' ', 'c', ' ', 'd', 'd', 'd'},
            { 'c', 'm', 'c', ' ', ' ', ' ', 'd', 'm', 'd'},
            { 'c', 'c', 'c', ' ', ' ', ' ', 'd', 'd', 'd'},
            { ' ', ' ', ' ', ' ', 's', ' ', ' ', ' ', ' '},
            { 'd', 'd', 'd', ' ', ' ', ' ', 'c', 'c', 'c'},
            { 'd', 'm', 'd', ' ', ' ', ' ', 'c', 'm', 'c'},
            { 'd', 'd', 'd', ' ', 'c', ' ', 'c', 'c', 'c'}
        },

        // 28
        {
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', 'd', 'c', ' ', ' ', ' ', ' ', 'd', 'c'},
            { ' ', 'd', 'c', ' ', 's', ' ', ' ', 'd', 'c'},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', 'd', 'c', ' ', ' ', ' ', ' ', ' ', ' '},
            { 'm', 'd', 'c', 'm', ' ', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', ' ', ' ', ' ', ' ', ' '}
        },

        // 29
        {
            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'c', ' '},
            { ' ', ' ', ' ', ' ', ' ', 'c', 'c', 'c', ' '},
            { ' ', ' ', ' ', ' ', 'c', 'c', 'c', 'c', ' '},
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 's'},
            { 'c', 'c', 'c', ' ', 'm', 'd', 'd', 'd', ' '},
            { ' ', 'c', 'c', ' ', ' ', ' ', ' ', ' ', ' '},
            { ' ', 'c', ' ', ' ', ' ', ' ', ' ', ' ', ' '}
        },

        // 30
        {
            { 'c', 'c', ' ', ' ', 'd', 'd', 'd', 'd', 'd'},
            { 'c', 'c', 'c', ' ', 'm', 'd', 'd', 'd', ' '},
            { ' ', 'c', 'c', 'c', 'd', ' ', ' ', 'd', ' '},
            { ' ', ' ', 'c', 'd', 's', ' ', 'd', 'm', ' '},
            { ' ', ' ', 'd', ' ', ' ', 'd', 'c', 'c', ' '},
            { ' ', 'd', ' ', ' ', 'd', 'c', 'c', 'c', 'c'},
            { ' ', 'd', 'd', 'd', ' ', ' ', ' ', 'c', ' '}
        },

        // 31
        {
            { 'd', ' ', ' ', ' ', 'c', ' ', ' ', ' ', ' '},
            { 'd', ' ', ' ', 'c', 'c', 'c', 'm', ' ', ' '},
            { 'd', ' ', 'c', 'c', 'c', 'c', 'c', ' ', ' '},
            { 'm', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { 'd', 's', ' ', ' ', 'd', ' ', ' ', ' ', ' '},
            { 'd', ' ', 'd', 'd', 'd', 'd', 'd', ' ', ' '},
            { 'd', ' ', ' ', 'm', 'd', ' ', ' ', ' ', ' '}
        },

        // 32
        {
            { 's', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { 'c', 'c', 'd', ' ', ' ', ' ', 'd', 'c', 'c'},
            { 'c', 'c', 'd', ' ', ' ', ' ', 'd', 'c', 'c'},
            { ' ', 'c', 'c', 'c', 'c', 'c', 'c', 'c', ' '},
            { ' ', ' ', 'm', 'c', 'c', 'c', 'm', ' ', ' '},
            { ' ', 'd', 'd', 'd', 'd', 'd', 'd', ' ', ' '},
            { ' ', ' ', ' ', 'c', 'c', 'c', ' ', ' ', ' '}
        },

        // 33
        {
            { 'c', 'c', 'c', ' ', ' ', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', ' ', 's', ' ', 'd', 'd', ' '},
            { 'c', 'c', 'c', ' ', ' ', 'd', 'd', 'd', 'd'},
            { ' ', ' ', ' ', ' ', ' ', 'd', 'd', 'd', 'd'},
            { ' ', 'm', 'c', ' ', ' ', 'm', 'd', 'd', ' '},
            { ' ', 'c', 'c', 'c', ' ', ' ', ' ', ' ', ' '},
            { 'c', 'c', 'c', 'c', 'c', ' ', ' ', ' ', ' '}
        },

        // 34
        {
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', ' '},
            { ' ', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'},
            { ' ', ' ', ' ', ' ', ' ', ' ', 'm', 'd', 'd'},
            { ' ', 'c', ' ', 's', ' ', ' ', 'd', 'd', 'd'},
            { 'c', 'c', 'c', 'c', ' ', ' ', ' ', 'd', 'd'},
            { 'm', 'c', 'c', 'c', ' ', ' ', ' ', ' ', 'd'},
            { ' ', ' ', ' ', 'c', 'c', 'c', 'c', ' ', ' '}
        },

        // 35
        {
            { 'c', 'c', ' ', ' ', ' ', ' ', ' ', 'c', 'c'},
            { ' ', 'c', ' ', ' ', 'd', ' ', ' ', 'c', 'm'},
            { ' ', 'c', ' ', 'd', 'd', 'd', 's', 'c', ' '},
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'},
            { ' ', ' ', 'm', 'd', 'd', 'd', ' ', ' ', ' '},
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'},
            { ' ', ' ', 'c', 'c', 'd', 'c', 'c', ' ', ' '}
        },

        // 36
        {
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'},
            { 'c', 'd', ' ', ' ', ' ', ' ', ' ', 'd', 'c'},
            { 'c', ' ', 'd', 'c', 'c', 'c', 'd', ' ', 'c'},
            { 'c', ' ', ' ', 'm', 's', 'm', ' ', ' ', 'c'},
            { 'c', ' ', 'd', 'c', 'c', 'c', 'd', ' ', 'c'},
            { 'c', 'd', ' ', 'd', 'd', 'd', ' ', 'd', 'c'},
            { 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'c'}
        },

        // 37
        {
            { 'c', 'd', 'c', 'd', 'c', 'd', 'c', 'd', 'c'},
            { 'm', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
            { 'd', 'd', 'd', ' ', 'c', 'd', ' ', ' ', ' '},
            { 's', 'c', 'd', 'c', 'd', 'c', 'd', 'c', 'd'},
            { 'd', 'd', 'd', ' ', 'c', 'd', ' ', ' ', ' '},
            { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
            { 'd', 'c', 'd', 'c', 'd', 'c', 'd', 'c', 'd'}
        },

        // 38
        {
            { ' ', 'm', 'd', 'd', 'd', 'd', 'm', ' ', ' '},
            { 'm', 'd', 'd', 'd', 'd', 'c', 'c', ' ', ' '},
            { 'd', 'd', 'd', 'd', 'c', 'c', 'c', 'c', ' '},
            { 'd', 'd', 'd', 'd', 'd', 'c', 'c', ' ', ' '},
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', ' ', ' '},
            { ' ', 'd', 'd', 'd', 'd', 'd', 's', ' ', ' '},
            { ' ', ' ', 'd', 'd', 'd', 'd', ' ', ' ', ' '}
        },

        // 39
        {
            { ' ', 'd', 'd', 'd', 'd', 'd', 'd', 'd', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', 'd', ' '},
            { ' ', 'd', 'm', 'd', 'd', 'd', ' ', 'd', ' '},
            { ' ', 'd', 'c', 'd', 's', 'd', 'c', 'd', ' '},
            { ' ', 'd', ' ', 'd', 'd', 'd', 'm', 'd', ' '},
            { ' ', 'd', 'c', 'c', 'c', 'c', 'c', 'd', ' '},
            { ' ', 'd', 'd', 'd', 'd', 'd', 'd', 'd', ' '}
        },

        // 40
        {
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'},
            { 'd', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'd'},
            { 'd', ' ', 's', ' ', ' ', ' ', ' ', ' ', 'm'},
            { 'd', ' ', ' ', 'c', 'd', 'd', 'c', ' ', 'd'},
            { 'd', ' ', ' ', ' ', ' ', 'm', ' ', ' ', 'd'},
            { 'd', 'c', 'c', 'c', 'c', 'c', 'c', 'c', 'd'},
            { 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd', 'd'}
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
    PowerUpFireballs *f;
    PowerUpShields *s;
    PowerUpTimer *t;
    switch (skillLevel) {

#pragma mark SkillLevel_Easy
        case SkillLevel_Easy:
            switch (grid) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 9;
                        g.chanceForTwoFireballs = 6;
                        g.chanceForThreeFireballs = 10;
                        g.chanceForFourFireballs = 15;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 25;

                    asteroidLaunchDelay = 3.0;
                    asteroidLaunchOdds = 12;
                    maxAsteroids = 2;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 3.0;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 60;
                    powerUpShieldsLaunchOdds = 15;
                    powerUpFireballsLaunchOdds = 10;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 10:
                case 11:
                case 12:
                case 13:
                case 14:
                case 15:
                case 16:
                case 17:
                case 18:
                case 19:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 8;
                        g.chanceForTwoFireballs = 5;
                        g.chanceForThreeFireballs = 9;
                        g.chanceForFourFireballs = 12;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 2.5;
                    asteroidLaunchOdds = 10;
                    maxAsteroids = 3;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.5;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 50;
                    powerUpShieldsLaunchOdds = 12;
                    powerUpFireballsLaunchOdds = 8;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 20:
                case 21:
                case 22:
                case 23:
                case 24:
                case 25:
                case 26:
                case 27:
                case 28:
                case 29:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 7;
                        g.chanceForTwoFireballs = 4;
                        g.chanceForThreeFireballs = 7;
                        g.chanceForFourFireballs = 10;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 2.0;
                    asteroidLaunchOdds = 8;
                    maxAsteroids = 3;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.0;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 50;
                    powerUpShieldsLaunchOdds = 11;
                    powerUpFireballsLaunchOdds = 7;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 30:
                case 31:
                case 32:
                case 33:
                case 34:
                case 35:
                case 36:
                case 37:
                case 38:
                case 39:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 6;
                        g.chanceForTwoFireballs = 4;
                        g.chanceForThreeFireballs = 5;
                        g.chanceForFourFireballs = 6;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 2.0;
                    asteroidLaunchOdds = 10;
                    maxAsteroids = 4;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.0;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 40;
                    powerUpShieldsLaunchOdds = 10;
                    powerUpFireballsLaunchOdds = 5;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                default:
                    break;
            }

            break;

#pragma mark SkillLevel_Normal
        case SkillLevel_Normal:
            switch (grid) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 6;
                        g.chanceForTwoFireballs = 4;
                        g.chanceForThreeFireballs = 7;
                        g.chanceForFourFireballs = 11;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 3.0;
                    asteroidLaunchOdds = 7;
                    maxAsteroids = 3;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.5;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 20;
                    powerUpShieldsLaunchOdds = 10;
                    powerUpFireballsLaunchOdds = 4;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 10:
                case 11:
                case 12:
                case 13:
                case 14:
                case 15:
                case 16:
                case 17:
                case 18:
                case 19:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 6;
                        g.chanceForTwoFireballs = 4;
                        g.chanceForThreeFireballs = 6;
                        g.chanceForFourFireballs = 9;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 2.5;
                    asteroidLaunchOdds = 6;
                    maxAsteroids = 3;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.5;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 15;
                    powerUpShieldsLaunchOdds = 8;
                    powerUpFireballsLaunchOdds = 3;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 20:
                case 21:
                case 22:
                case 23:
                case 24:
                case 25:
                case 26:
                case 27:
                case 28:
                case 29:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 5;
                        g.chanceForTwoFireballs = 3;
                        g.chanceForThreeFireballs = 5;
                        g.chanceForFourFireballs = 8;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 30;

                    asteroidLaunchDelay = 2.0;
                    asteroidLaunchOdds = 5;
                    maxAsteroids = 4;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.0;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 10;
                    powerUpShieldsLaunchOdds = 6;
                    powerUpFireballsLaunchOdds = 3;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                case 30:
                case 31:
                case 32:
                case 33:
                case 34:
                case 35:
                case 36:
                case 37:
                case 38:
                case 39:

                    for (Guardian *g in guardians) {
                        g.baseFireDelay = 4;
                        g.chanceForTwoFireballs = 2;
                        g.chanceForThreeFireballs = 4;
                        g.chanceForFourFireballs = 5;
                        g.fireDelay = (arc4random() % g.baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
                    }

                    timer = timeToCompleteGrid = 35;

                    asteroidLaunchDelay = 2.0;
                    asteroidLaunchOdds = 4;
                    maxAsteroids = 4;
                    asteroidSpeed = 60;
                    for (int i = 0; i < maxAsteroids; ++i) {
                        Asteroid *asteroid = [[Asteroid alloc] initLaunchLocationWithSpeed:asteroidSpeed];
                        [asteroids addObject:asteroid];
                        [asteroid release];
                    }

                    powerUpLaunchDelay = 2.0;
                    powerUpSpeed = 50;
                    powerUpTimerLaunchOdds = 5;
                    powerUpShieldsLaunchOdds = 4;
                    powerUpFireballsLaunchOdds = 2;
                    f = [[PowerUpFireballs alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:f];
                    [f release];
                    s = [[PowerUpShields alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:s];
                    [s release];
                    t = [[PowerUpTimer alloc] initLaunchLocationWithSpeed:powerUpSpeed];
                    [powerUps addObject:t];
                    [t release];

                    break;

                    default:
                    break;
            }

            break;

#pragma mark SkillLevel_Hard
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
    for (TraversingEntity *p in powerUps) {
        p.state = EntityState_Dead;
    }
}

- (void)powerUpFireballs {
    for (Guardian *g in guardians) {
        for (Fireball *f in g.fireballs) {
            f.state = EntityState_Idle;
        }
    }
}

- (void)launchAsteroidWithDelta:(float)aDelta; {
    asteroidTimer += aDelta;
    if (asteroidTimer > asteroidLaunchDelay) {
        if (1 == (arc4random() % asteroidLaunchOdds + 1)) {
            for (Asteroid *a in asteroids) {
                if (a.state == EntityState_Idle) {
                    [a initLaunchLocationWithSpeed:asteroidSpeed];
                    a.state = EntityState_Alive;
                    return;
                }
            }
        }
        asteroidTimer = 0;
    }
}

- (void)launchPowerUpWithDelta:(float)aDelta {
    TraversingEntity *p;
    powerUpTimer += aDelta;
    if (powerUpTimer > powerUpLaunchDelay) {
        powerUpTimer = 0;
        if (1 == (arc4random() % powerUpFireballsLaunchOdds + 1)) {
            p = [powerUps objectAtIndex:0];
            if (p.state == EntityState_Idle) {
                [p initLaunchLocationWithSpeed:powerUpSpeed];
                p.state = EntityState_Alive;
            }
        }
        if (1 == (arc4random() % powerUpShieldsLaunchOdds + 1)) {
            p = [powerUps objectAtIndex:1];
            if (p.state == EntityState_Idle) {
                [p initLaunchLocationWithSpeed:powerUpSpeed];
                p.state = EntityState_Alive;
            }
        }
        if (trackingTime) {
            if (1 == (arc4random() % powerUpTimerLaunchOdds + 1)) {
                p = [powerUps objectAtIndex:2];
                if (p.state == EntityState_Idle) {
                    [p initLaunchLocationWithSpeed:powerUpSpeed];
                    p.state = EntityState_Alive;
                }
            }
        }
    }
}

- (void)updateScore {
    score += currentCubeValue;
    [self freeShipCheck];
}

- (void)freeShipCheck {
    if (score >= nextFreeShip) {
        [sharedSoundManager playSoundWithKey:@"free_ship"];
        [sharedSoundManager fadeMusicVolumeFrom:0.0 toVolume:sharedSoundManager.musicVolume duration:5.0 stop:NO];
        ++playerLives;
        nextFreeShip += freeShipValue;
    }
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
        if (playInitTimerSound) {
            [sharedSoundManager playSoundWithKey:@"timer_powerup"
                                            gain:1.0
                                           pitch:1.0
                                        location:CGPointMake(0, 0)
                                      shouldLoop:NO];
            playInitTimerSound = FALSE;
        }
        initingTimerTracker += aDelta;
        if (initingTimerTracker > timeToInitTimerDisplay) {
            initingTimer = FALSE;
            initingTimerTracker = 0;
            if (powerUpTimerReInit) {
                trackingTime = TRUE;
                powerUpTimerReInit = FALSE;
            }
        }
    }
}

- (void)powerUpTimer {
    trackingTime = FALSE;
    initingTimer = TRUE;
    powerUpTimerReInit = TRUE;
    timer = timeToCompleteGrid;
}

- (void)calculateTimerBonus {
    timerBonusScore = 1000 * timer;
    if (timerBonusScore > 0) {
        timerBonus = TRUE;
    }
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
                [sharedSoundManager playMusicWithKey:@"background_music" timesToRepeat:-1];
                return;
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
                return;
            }
            lastTimeInLoop = CACurrentMediaTime();
            break;

#pragma mark SceneState_LevelPauseAndInit
        case SceneState_LevelPauseAndInit:
            [starfield updateWithDelta:aDelta];
            for (Guardian *g in guardians) {
                [g updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 1.5) {
                return;
            }
            if (lastTimeInLoop) {
                score += timerBonusScore;
                [self freeShipCheck];
                timerBonusScore = 0;
                if (currentGrid == numberOfGrids) {
                    sceneState = SceneState_AllGridsCompleted;
                    [sharedSoundManager pauseMusic];
                    [sharedSoundManager playSoundWithKey:@"all_grids_completed"];
                    [sharedSoundManager fadeMusicVolumeFrom:0.0 toVolume:sharedSoundManager.musicVolume duration:5.0 stop:NO];
                    [sharedSoundManager resumeMusic];
                    return;
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
                [sharedSoundManager resumeMusic];
                return;
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
            for (TraversingEntity *p in powerUps) {
                [p updateWithDelta:aDelta];
            }
            if (CACurrentMediaTime() - lastTimeInLoop < 1.0) {
                return;
            }
            if (lastTimeInLoop) {
                [ship release];
                ship = [[Ship alloc] initWithPixelLocation:startingShipPosition];
                sceneState = SceneState_Running;
                lastTimeInLoop = 0;
                return;
            }
            lastTimeInLoop = CACurrentMediaTime();
            break;

#pragma mark SceneState_Running
        case SceneState_Running:
            [self updateTimerWithDelta:aDelta];
            [self launchAsteroidWithDelta:aDelta];
            [self launchPowerUpWithDelta:aDelta];
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
            for (TraversingEntity *p in powerUps) {
                [p updateWithDelta:aDelta];
                if (p.state == EntityState_Alive && ship.state != EntityState_Dead) {
                    [ship checkForCollisionWithEntity:p];
                }
            }

            [ship updateWithDelta:aDelta];
            if (ship.state == EntityState_Dead &&
                ship.explosion.animation.state == kAnimationState_Stopped) {
                if (playerLives == 0) {
                    sceneState = SceneState_GameOver;
                    [sharedSoundManager pauseMusic];
                    [sharedSoundManager playSoundWithKey:@"game_over"];
                    [sharedSoundManager fadeMusicVolumeFrom:0.0 toVolume:sharedSoundManager.musicVolume duration:5.0 stop:NO];
                    [sharedSoundManager resumeMusic];
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
#pragma mark SceneState_AllGridsCompleted
        case SceneState_GameOver:
        case SceneState_AllGridsCompleted:
            [self launchAsteroidWithDelta:aDelta];
            [self launchPowerUpWithDelta:aDelta];
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
            for (TraversingEntity *p in powerUps) {
                [p updateWithDelta:aDelta];
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
            for (TraversingEntity *p in powerUps) {
                [p render];
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
            for (TraversingEntity *p in powerUps) {
                [p render];
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
                                             justification:BitmapFontJustification_MiddleCentered
                                                      text:@"Game Over"];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                       justification:BitmapFontJustification_TopCentered
                                                text:@"Tap to play again, starting at current grid."];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                       justification:BitmapFontJustification_MiddleCentered
                                                text:@"Double Tap to return to main menu."];

            [sharedImageRenderManager renderImages];
            break;

#pragma mark SceneState_AllGridsCompleted
        case SceneState_AllGridsCompleted:
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
            for (TraversingEntity *p in powerUps) {
                [p render];
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
                                             justification:BitmapFontJustification_MiddleCentered
                                                      text:@"Game Over"];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                       justification:BitmapFontJustification_TopCentered
                                                text:@"Congratulations! All grids completed."];

            [statusFont renderStringJustifiedInFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT/2-30*appDelegate.heightScaleFactor)
                                       justification:BitmapFontJustification_MiddleCentered
                                                text:@"Double Tap to return to main menu."];

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

    if (sceneState != SceneState_GameOver && sceneState != SceneState_AllGridsCompleted) {
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

            if (abs_dx > drag_min || abs_dy > drag_min) {
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
        if (appDelegate.retinaDisplay) {
            loc.x *= 2; loc.y *= 2;
        }
        if (CGRectContainsPoint(CGRectMake(appDelegate.GUARDIAN_RIGHT_BASE, 0,
                                           79*appDelegate.widthScaleFactor, 76*appDelegate.heightScaleFactor), loc)) {
            [self.viewController showPauseView];
            return;
        }
    }

    switch (sceneState) {

#pragma mark SceneState_Running
        case SceneState_Running:
            if (numTaps == tapsNeededToToggleThrust) {
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

#pragma mark SceneState_AllGridsCompleted
        case SceneState_AllGridsCompleted:
            if (numTaps == 2) {
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
