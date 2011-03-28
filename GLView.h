//
//  GLView.h
//  CubeStorm
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
@class CubeStormAppDelegate;
@class OpenGLViewController;

@class Ship;

typedef enum {
    SceneState_Running,
    SceneState_GameBegin,
    SceneState_GuardianTransport,
    SceneState_LevelPauseAndInit,
    SceneState_ShipRespawn,
} SceneState;

typedef enum {
    SkillLevel_Easy,
    SkillLevel_Normal,
    SkillLevel_Hard,
} SkillLevel;

@interface GLView : GLESGameState {

    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *viewController;

    SceneState sceneState;
    double lastTimeInLoop;

    ImageRenderManager *sharedImageRenderManager;
    ParticleEmitter *starfield;

    NSMutableArray *guardians;
    NSMutableArray *cubes;
    NSMutableArray *spikeMines;
    Ship *ship;
    int cubeCount;
    int currentGrid, numberOfGrids;

    CGFloat drag_min_x;
    CGFloat drag_min_y;

    CGPoint startingShipPosition;
    SkillLevel skillLevel;

}

@property (nonatomic, retain) OpenGLViewController *viewController;
@property (nonatomic, assign) int cubeCount;
@property (nonatomic, assign) SceneState sceneState;
@property (nonatomic, assign) double lastTimeInLoop;
@property (nonatomic, readonly) int currentGrid;

- (void)initGame;
- (void)initGuardians;
- (void)initGrid:(int)grid;
- (void)resetGuardiansAndClearGrid;

@end
