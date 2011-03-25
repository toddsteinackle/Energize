//
//  Guardian.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

typedef enum {
    guardian_top,
    guardian_right,
    guardian_bottom,
    guardian_left
} guardianZone;

@interface Guardian : AbstractEntity {

    Animation *firing;
    Animation *teleporting;
    guardianZone zone;
    float firingTimer;
    NSMutableArray *fireballs;
    int numberOfFireballs, fireball_counter;
    bool justFired;
    int baseFireDelay;
    float fireDelay;
}

@property (readonly, nonatomic) NSMutableArray *fireballs;

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle;
- (void)movementWithDelta:(float)aDelta;
- (void)fire;

@end
