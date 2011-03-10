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

@interface GLView : GLESGameState {

    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *viewController;

    int sceneState;

    ImageRenderManager *sharedImageRenderManager;
    ParticleEmitter *starfield;
    Asteroid *asteroid;

}

@property (nonatomic, retain) OpenGLViewController *viewController;

@end
