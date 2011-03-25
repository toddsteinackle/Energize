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
} SceneState;

@interface GLView : GLESGameState {

    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *viewController;

    SceneState sceneState;
    double lastTimeInLoop;

    ImageRenderManager *sharedImageRenderManager;
    ParticleEmitter *starfield;

    NSMutableArray *guardians;
    NSMutableArray *cubes;
    Ship *ship;
    int cubeCount;
    int currentLevel, numberOfLevels;

    CGFloat drag_min_x;
    CGFloat drag_min_y;

}

@property (nonatomic, retain) OpenGLViewController *viewController;
@property (nonatomic, assign) int cubeCount;
@property (nonatomic, assign) SceneState sceneState;
@property (nonatomic, assign) double lastTimeInLoop;

- (void)initGuardians;
- (void)initLevel:(int)level;
- (void)resetFireballs;

@end
