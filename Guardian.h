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
    bool justFired, launchingMultipleFireballs;
    int baseFireDelay;
    int chanceForTwoFireballs, chanceForThreeFireballs, chanceForFourFireballs;
    float fireDelay;
    int shotCounter;
    bool canFire;
}

@property (readonly, nonatomic) NSMutableArray *fireballs;
@property (assign, nonatomic) float firingTimer;
@property (assign, nonatomic) bool canFire;

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle;
- (void)movementWithDelta:(float)aDelta;
- (void)fire;

@end
