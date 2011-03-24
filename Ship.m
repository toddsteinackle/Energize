//
//  Ship.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Ship.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "CubeStormAppDelegate.h"
#import "Cube.h"


@implementation Ship

@synthesize direction;
@synthesize isThrusting;

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 41;
        height = 41;

        teleporting = [[Animation alloc] init];
        float delay = 0.1f;
        int frames = 24;
        [self setupAnimation:teleporting
                 spriteSheet:@"ship-teleport.png"
              animationDelay:delay numFrames:frames];
        frames = 1;
        [self setupAnimation:teleporting
                 spriteSheet:@"ship-up.png"
              animationDelay:delay numFrames:frames];

        frames = 4;
        up = [[Animation alloc] init];
        [self setupAnimation:up spriteSheet:@"ship-up-boost1.png" animationDelay:delay numFrames:frames];

        upThrust = [[Animation alloc] init];
        [self setupAnimation:upThrust spriteSheet:@"ship-up-boost2.png" animationDelay:delay numFrames:frames];

        down = [[Animation alloc] init];
        [self setupAnimation:down spriteSheet:@"ship-down-boost1.png" animationDelay:delay numFrames:frames];

        downThrust = [[Animation alloc] init];
        [self setupAnimation:downThrust spriteSheet:@"ship-down-boost2.png" animationDelay:delay numFrames:frames];

        right = [[Animation alloc] init];
        [self setupVerticalAnimation:right spriteSheet:@"ship-right-boost1.png"
                      animationDelay:delay numFrames:frames];

        rightThrust = [[Animation alloc] init];
        [self setupVerticalAnimation:rightThrust spriteSheet:@"ship-right-boost2.png"
                      animationDelay:delay numFrames:frames];

        left = [[Animation alloc] init];
        [self setupVerticalAnimation:left spriteSheet:@"ship-left-boost1.png"
                      animationDelay:delay numFrames:frames];

        leftThrust = [[Animation alloc] init];
        [self setupVerticalAnimation:leftThrust spriteSheet:@"ship-left-boost2.png"
                      animationDelay:delay numFrames:frames];

        frames = 12;
        width = 61;
        delay = 0.075;
        warp = [[Animation alloc] init];
        [self setupAnimation:warp
                 spriteSheet:@"ship-warp.png"
              animationDelay:delay numFrames:frames];

    }
    width = 41;
    animation = teleporting;
    animation.type = kAnimationType_Once;
    state = EntityState_Transporting;
    currentSpeed = 0;
    direction = ship_up;
    isThrusting = FALSE;
    collisionWidth = appDelegate.widthScaleFactor * width *.95;
    collisionHeight = appDelegate.heightScaleFactor * height;
    collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
    collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;
    return self;
}

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    switch (direction) {
        case ship_up:
            dx = 0;
            if (pixelLocation.y > appDelegate.SHIP_TOP_BOUND - appDelegate.SHIP_HEIGHT) {
                dy = 0;
            } else {
                dy = currentSpeed;
            }
            break;
        case ship_down:
            dx = 0;
            if (pixelLocation.y < appDelegate.SHIP_BOTTOM_BOUND) {
                dy = 0;
            } else {
                dy = -currentSpeed;
            }
            break;
        case ship_left:
            dy = 0;
            if (pixelLocation.x < appDelegate.SHIP_LEFT_BOUND) {
                dx = 0;
            } else {
                dx = -currentSpeed;
            }
            break;
        case ship_right:
            dy = 0;
            if (pixelLocation.x > appDelegate.SHIP_RIGHT_BOUND - appDelegate.SHIP_WIDTH) {
                dx = 0;
            } else {
                dx = currentSpeed;
            }
            break;

        default:
            break;
    }

}

- (void)updateWithDelta:(float)aDelta {
    [animation updateWithDelta:aDelta];

    switch (state) {
        case EntityState_Transporting:
            if (animation.state == kAnimationState_Stopped) {
                state = EntityState_Idle;
            }
            break;

        case EntityState_Idle:
            break;

        case EntityState_Alive:
            if (isThrusting) {
                switch (direction) {
                    case ship_up:
                        animation = upThrust;
                        currentSpeed = appDelegate.SHIP_TURBO_SPEED_VERTICAL;
                        break;

                    case ship_down:
                        animation = downThrust;
                        currentSpeed = appDelegate.SHIP_TURBO_SPEED_VERTICAL;
                        break;

                    case ship_right:
                        animation = rightThrust;
                        currentSpeed = appDelegate.SHIP_TURBO_SPEED_HORIZONTAL;
                        break;

                    case ship_left:
                        animation = leftThrust;
                        currentSpeed = appDelegate.SHIP_TURBO_SPEED_HORIZONTAL;
                        break;

                    default:
                        break;
                }
            } else {

                switch (direction) {
                    case ship_up:
                        animation = up;
                        currentSpeed = appDelegate.SHIP_SPEED_VERTICAL;
                        break;

                    case ship_down:
                        animation = down;
                        currentSpeed = appDelegate.SHIP_SPEED_VERTICAL;
                        break;

                    case ship_right:
                        animation = right;
                        currentSpeed = appDelegate.SHIP_SPEED_HORIZONTAL;
                        break;

                    case ship_left:
                        animation = left;
                        currentSpeed = appDelegate.SHIP_SPEED_HORIZONTAL;
                        break;

                    default:
                        break;
                }
            }
            [self movementWithDelta:aDelta];
            if (appDelegate.glView.cubeCount == 0) {
                animation = warp;
                animation.type = kAnimationType_Once;
                state = EntityState_Warping;
            }
            break;

        case EntityState_Warping:
            if (animation.state == kAnimationState_Stopped) {
                appDelegate.glView.sceneState = SceneState_LevelPauseAndInit;
                appDelegate.glView.lastTimeInLoop = 0;
            }
            break;


        default:
            break;
    }
}

- (void)render {
#ifdef COLLISION_DEBUG
    [super render];
#endif
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                       scale:Scale2fMake(scaleWidth, scaleHeight)
                    rotation:rotationAngle];

}

- (void)checkForCollisionWithCube:(Cube *)cube {
    if ((pixelLocation.y + collisionYOffset >= cube.collisionBox.y + cube.collisionYOffset + cube.collisionHeight) ||
        (pixelLocation.x + collisionXOffset >= cube.collisionBox.x + cube.collisionXOffset + cube.collisionWidth) ||
        (cube.collisionBox.y + cube.collisionYOffset >= pixelLocation.y + collisionYOffset + collisionHeight) ||
        (cube.collisionBox.x + cube.collisionXOffset >= pixelLocation.x + collisionXOffset + collisionWidth)) {
        return;
    }
    cube.state = EntityState_Dead;
    appDelegate.glView.cubeCount--;
#ifdef GAMEPLAY_DEBUG
    NSLog(@"cubeCount -- %i", appDelegate.glView.cubeCount);
#endif

}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
