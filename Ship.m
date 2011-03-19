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
#import "Constants.h"


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
    animation = teleporting;
    animation.type = kAnimationType_Once;
    state = EntityState_Transporting;
    currentSpeed = SHIP_SPEED;
    return self;
}

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    switch (direction) {
        case ship_up:
            dx = 0;
            dy = currentSpeed;
            break;
        case ship_down:
            dx = 0;
            dy = -currentSpeed;
            break;
        case ship_left:
            dy = 0;
            dx = -currentSpeed;
            break;
        case ship_right:
            dy = 0;
            dx = currentSpeed;
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
                state = EntityState_Alive;
                animation = up;
            }
            break;

        case EntityState_Alive:
            if (isThrusting) {
                currentSpeed = SHIP_TURBO_SPEED;
                switch (direction) {
                    case ship_up:
                        animation = upThrust;
                        break;

                    case ship_down:
                        animation = downThrust;
                        break;

                    case ship_right:
                        animation = rightThrust;
                        break;

                    case ship_left:
                        animation = leftThrust;
                        break;

                    default:
                        break;
                }
            } else {
                currentSpeed = SHIP_SPEED;
                switch (direction) {
                    case ship_up:
                        animation = up;
                        break;

                    case ship_down:
                        animation = down;
                        break;

                    case ship_right:
                        animation = right;
                        break;

                    case ship_left:
                        animation = left;
                        break;

                    default:
                        break;
                }
            }

            [self movementWithDelta:aDelta];

            break;

        default:
            break;
    }
}

- (void)render {
#ifdef COLLISION_DEBUG
    [super render];
#endif
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
