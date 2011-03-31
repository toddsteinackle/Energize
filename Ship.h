//
//  Ship.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

typedef enum {
    ship_up,
    ship_down,
    ship_right,
    ship_left
} shipDirection;

@class Cube;
@class Explosion;
@class Shield;

@interface Ship : AbstractEntity {

    Animation *teleporting;
    Animation *up;
    Animation *down;
    Animation *upThrust;
    Animation *downThrust;
    Animation *warp;
    Animation *right;
    Animation *left;
    Animation *rightThrust;
    Animation *leftThrust;

    shipDirection direction;
    bool isThrusting;
    CGFloat currentSpeed;
    Explosion *explosion;
    bool exploding;
    float idleTimer, safePeriod;
    bool justAppeared;
    Shield *shield;
    bool colliding;
    CGPoint cubeLocation;
}

@property (nonatomic, assign) shipDirection direction;
@property (nonatomic, assign) bool isThrusting;
@property (nonatomic, readonly) Explosion *explosion;

- (void)movementWithDelta:(float)aDelta;
- (void)checkForCollisionWithEntityRenderedCenter:(AbstractEntity *)otherEntity;
- (void)explode;

@end
