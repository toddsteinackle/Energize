//
//  GLView.h
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GLESGameState.h"

@class Image;
@class ImageRenderManager;
@class SpriteSheet;
@class PackedSpriteSheet;
@class Animation;
@class BitmapFont;
@class ParticleEmitter;
@class OpenGLViewController;
@class SoundManager;

@class Ship;

typedef enum {
    SceneState_Running,
    SceneState_GameBegin,
    SceneState_GuardianTransport,
    SceneState_LevelPauseAndInit,
    SceneState_ShipRespawn,
    SceneState_GameOver,
    SceneState_AllGridsCompleted,
} SceneState;

typedef enum {
    SkillLevel_Easy,
    SkillLevel_Normal,
    SkillLevel_Hard,
} SkillLevel;

@interface GLView : GLESGameState {

    OpenGLViewController *viewController;

    SceneState sceneState;
    double lastTimeInLoop;

    ImageRenderManager *sharedImageRenderManager;
    SoundManager *sharedSoundManager;
    ParticleEmitter *starfield;

    NSMutableArray *guardians;
    NSMutableArray *cubes;
    NSMutableArray *spikeMines;
    NSMutableArray *asteroids;
    NSMutableArray *powerUps;
    Ship *ship;
    int cubeCount;
    int currentGrid, numberOfGrids, gridDifficulty;
    int lastGridPlayed_easy, lastGridPlayed_normal, lastGridPlayed_hard;

    CGFloat drag_min;

    CGPoint startingShipPosition;
    SkillLevel skillLevel;

    BitmapFont *statusFont;
    BitmapFont *largeMessageFont;
    Image *statusShip;
    Image *timerBar;
    Image *pauseButton;
    int score, timerBonusScore;
    int nextFreeShip, freeShipValue;
    int currentCubeValue;
    int playerLives;
    int maxAsteroids, asteroidLaunchOdds;
    int powerUpTimerLaunchOdds, powerUpFireballsLaunchOdds, powerUpShieldsLaunchOdds;
    bool gameContinuing;
    bool trackingTime, beatTimer, initingTimer, timerBonus, powerUpTimerReInit, playInitTimerSound;
    bool shipThrustingDefault;
    bool randomGridPlayOption;

    CGFloat timer, timeToCompleteGrid, initingTimerTracker, timeToInitTimerDisplay;
    CGFloat asteroidSpeed, powerUpSpeed;

    double asteroidLaunchDelay, asteroidTimer;
    double powerUpLaunchDelay, powerUpTimer;

    int tapsNeededToToggleThrust;

}

@property (nonatomic, retain) OpenGLViewController *viewController;
@property (nonatomic, assign) int cubeCount;
@property (nonatomic, assign) SceneState sceneState;
@property (nonatomic, assign) SkillLevel skillLevel;
@property (nonatomic, assign) double lastTimeInLoop;
@property (nonatomic, assign) int currentGrid;
@property (nonatomic, assign) int gridDifficulty;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int playerLives;
@property (nonatomic, assign) bool trackingTime;
@property (nonatomic, assign) bool beatTimer;
@property (nonatomic, assign) bool playInitTimerSound;
@property (nonatomic, assign) bool shipThrustingDefault;
@property (nonatomic, assign) int tapsNeededToToggleThrust;
@property (nonatomic, assign) CGFloat drag_min;
@property (nonatomic, assign) bool randomGridPlayOption;
@property (nonatomic, assign) int lastGridPlayed_easy;
@property (nonatomic, assign) int lastGridPlayed_normal;
@property (nonatomic, assign) int lastGridPlayed_hard;

- (void)initGame;
- (void)initGuardians;
- (void)initGrid:(int)grid;
- (void)resetGuardiansAndClearGrid;
- (void)updateScore;
- (void)updateStatus;
- (void)handleSingleTap:(NSDictionary *)touches;
- (void)updateTimerWithDelta:(float)aDelta;
- (void)calculateTimerBonus;
- (void)launchAsteroidWithDelta:(float)aDelta;
- (void)launchPowerUpWithDelta:(float)aDelta;
- (void)powerUpFireballs;
- (void)powerUpTimer;
- (void)freeShipCheck;
- (void)loadSounds;
- (void)removeSounds;

@end
