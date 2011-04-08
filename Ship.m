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
#import "Fireball.h"
#import "Explosion.h"
#import "SpikeMine.h"
#import "Shield.h"
#import "Asteroid.h"
#import "PowerUpFireballs.h"


@implementation Ship

@synthesize direction;
@synthesize isThrusting;
@synthesize explosion;

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 41;
        height = 41;

        teleporting = [[Animation alloc] init];
        float delay = 0.08f;
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
    isThrusting = TRUE;
    collisionWidth = appDelegate.widthScaleFactor * width *.9;
    collisionHeight = appDelegate.heightScaleFactor * height *.9;
    collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
    collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;
    explosion = [[Explosion alloc] initWithPixelLocation:CGPointMake(0, 0)];
    exploding = FALSE;
    justAppeared = TRUE;
    idleTimer = 0;
    safePeriod = 0.5;
    shield = [[Shield alloc] initWithPixelLocation:CGPointMake(0, 0)];
    colliding = FALSE;
    return self;
}

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    if (shield.state == EntityState_Alive) {
        shield.pixelLocation = CGPointMake(pixelLocation.x, pixelLocation.y);
    }

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
    [explosion updateWithDelta:aDelta];
    [shield updateWithDelta:aDelta];

    switch (state) {
        case EntityState_Transporting:
            if (animation.state == kAnimationState_Stopped) {
                state = EntityState_Idle;
                if (appDelegate.glView.sceneState == SceneState_Running) {
                    appDelegate.glView.trackingTime = TRUE;
                }
            }
            break;

        case EntityState_Idle:
            idleTimer += aDelta;
            if (idleTimer > safePeriod) {
                justAppeared = FALSE;
                idleTimer = 0;
            }
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
                if (appDelegate.glView.trackingTime) {
                    appDelegate.glView.beatTimer = TRUE;
                    appDelegate.glView.trackingTime = FALSE;
                    [appDelegate.glView calculateTimerBonus];
                }
                [appDelegate.glView resetGuardiansAndClearGrid];
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

        case EntityState_Dead:
            if (appDelegate.glView.cubeCount == 0) {
                if (appDelegate.glView.trackingTime) {
                    appDelegate.glView.beatTimer = TRUE;
                    appDelegate.glView.trackingTime = FALSE;
                    [appDelegate.glView calculateTimerBonus];
                }
                [appDelegate.glView resetGuardiansAndClearGrid];
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
    switch (state) {
        case EntityState_Transporting:
        case EntityState_Alive:
        case EntityState_Warping:
        case EntityState_Idle:
            [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                               scale:Scale2fMake(scaleWidth, scaleHeight)
                            rotation:rotationAngle];
            break;
        default:
            break;
    }
    [shield render];
    [explosion render];
}

- (void)checkForCollisionWithEntityRenderedCenter:(AbstractEntity *)otherEntity {
    if ((pixelLocation.y + collisionYOffset >= otherEntity.collisionBox.y + otherEntity.collisionYOffset + otherEntity.collisionHeight) ||
        (pixelLocation.x + collisionXOffset >= otherEntity.collisionBox.x + otherEntity.collisionXOffset + otherEntity.collisionWidth) ||
        (otherEntity.collisionBox.y + otherEntity.collisionYOffset >= pixelLocation.y + collisionYOffset + collisionHeight) ||
        (otherEntity.collisionBox.x + otherEntity.collisionXOffset >= pixelLocation.x + collisionXOffset + collisionWidth)) {
        if (otherEntity.pixelLocation.x == cubeLocation.x && otherEntity.pixelLocation.y == cubeLocation.y) {
            colliding = FALSE;
        }
        return;
    }
    if ([otherEntity isKindOfClass:[Cube class]]) {
        Cube *c = (Cube*)otherEntity;
        if (c.isDoubleCube) {
            c.isDoubleCube = FALSE;
            [c changeAnimation];
            [appDelegate.glView updateScore];
            colliding = TRUE;
            cubeLocation = c.pixelLocation;
            return;
        }
        if (!colliding) {
            otherEntity.state = EntityState_Dead;
            appDelegate.glView.cubeCount--;
            [appDelegate.glView updateScore];
#ifdef GAMEPLAY_DEBUG
            NSLog(@"cubeCount -- %i", appDelegate.glView.cubeCount);
#endif
            return;
        }
    }
    if ([otherEntity isKindOfClass:[SpikeMine class]]) {
#ifdef GAMEPLAY_DEBUG
        NSLog(@"ship spikeball collision");
#endif
        state = EntityState_Dead;
        appDelegate.glView.playerLives--;
        if (!exploding) {
            otherEntity.state = EntityState_Dead;
            [self explode];
            return;
        }
    }

}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {
    if ((pixelLocation.y + collisionYOffset >= otherEntity.pixelLocation.y + otherEntity.collisionYOffset + otherEntity.collisionHeight) ||
        (pixelLocation.x + collisionXOffset >= otherEntity.pixelLocation.x + otherEntity.collisionXOffset + otherEntity.collisionWidth) ||
        (otherEntity.pixelLocation.y + otherEntity.collisionYOffset >= pixelLocation.y + collisionYOffset + collisionHeight) ||
        (otherEntity.pixelLocation.x + otherEntity.collisionXOffset >= pixelLocation.x + collisionXOffset + collisionWidth)) {
        return;
    }

    if (state == EntityState_Transporting) {
        return;
    }
    if (state == EntityState_Idle && justAppeared) {
        otherEntity.state = EntityState_Dead;
        shield.pixelLocation = CGPointMake(pixelLocation.x, pixelLocation.y);
        shield.state = EntityState_Alive;
        shield.animation.state = kAnimationState_Running;
        return;
    }

    if ([otherEntity isKindOfClass:[Fireball class]] ||
        [otherEntity isKindOfClass:[Asteroid class]]) {
#ifdef GAMEPLAY_DEBUG
        NSLog(@"ship fireball or asteroid collision");
#endif
        state = EntityState_Dead;
        appDelegate.glView.playerLives--;
        if (!exploding) {
            otherEntity.state = EntityState_Idle;
            [self explode];
            return;
        }
    }

    if ([otherEntity isKindOfClass:[PowerUpFireballs class]]) {
        otherEntity.state = EntityState_Idle;
        [appDelegate.glView powerUpFireballs];
    }
}

- (void)explode {
    explosion.pixelLocation = CGPointMake(pixelLocation.x, pixelLocation.y);
    explosion.state = EntityState_Alive;
    explosion.animation.state = kAnimationState_Running;
    exploding = TRUE;
}

- (void)dealloc {
    [teleporting release];
    [up release];
    [down release];
    [upThrust release];
    [downThrust release];
    [warp release];
    [right release];
    [left release];
    [rightThrust release];
    [leftThrust release];
    [explosion release];
    [shield release];
    [super dealloc];
}

@end
