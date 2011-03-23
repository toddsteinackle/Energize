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
    SceneState_TransitionIn,
    SceneState_Running,
} SceneState;

@interface GLView : GLESGameState {

    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *viewController;

    UISwipeGestureRecognizer  *swipeLeftGestureRecognizer;
    UISwipeGestureRecognizer  *swipeRightGestureRecognizer;
    UISwipeGestureRecognizer  *swipeUpGestureRecognizer;
    UISwipeGestureRecognizer  *swipeDownGestureRecognizer;

    SceneState sceneState;
    double lastTimeInLoop;

    ImageRenderManager *sharedImageRenderManager;
    ParticleEmitter *starfield;

    NSMutableArray *guardians;
    NSMutableArray *cubes;
    Ship *ship;
    int cubeCount;

}

@property (nonatomic, retain) OpenGLViewController *viewController;
@property (nonatomic, assign) int cubeCount;

- (void)initGuardians;
- (void)handleSwipes:(UISwipeGestureRecognizer *)paramSender;
- (void)initLevel;

@end
