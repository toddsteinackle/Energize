/*
 *  Globals.h
 *  CubeStorm
 *
 *  Created by Todd Steinackle on 3/1/11.
 *  Copyright 2011 The No Quarter Arcade. All rights reserved.
 *
 */

#pragma mark -
#pragma mark Enumerators

// Scene States
enum SceneState {
    SceneState_TransitionIn,
    SceneState_Running,
    SceneState_EntitiesAppearing,
};

// Entity states
enum EntityState {
    EntityState_Idle,
};

#pragma mark -
#pragma mark Constants

#define IPHONE_HEIGHT 320
#define IPHONE_WIDTH 480
#define IPAD_HEIGHT 768
#define IPAD_WIDTH 1024

#define GUARDIAN_WIDTH 82
