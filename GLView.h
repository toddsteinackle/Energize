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

@class Asteroid;
@class Cube;
@class SpikeMine;
@class Explosion;
@class Guardian;
@class Fireball;
@class Ship;

@interface GLView : GLESGameState {

    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *viewController;

    int sceneState;
    double lastTimeInLoop;

    ImageRenderManager *sharedImageRenderManager;
    ParticleEmitter *starfield;

    NSMutableArray *guardians;

    Asteroid *asteroid;
    Cube *cube;
    SpikeMine *spikeMine;
    Explosion *explosion;
    Fireball *fireball;
    Ship *ship;

}

@property (nonatomic, retain) OpenGLViewController *viewController;

- (void)initGuardians;

@end
