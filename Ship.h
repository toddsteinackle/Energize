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
}

@property (nonatomic, assign) shipDirection direction;
@property (nonatomic, assign) bool isThrusting;

- (void)movementWithDelta:(float)aDelta;
- (void)checkForCollisionWithCube:(Cube *)cube;

@end
