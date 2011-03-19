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

    Animation *seeking;
    Animation *teleporting;
    float rotationAngle;
    guardianZone zone;
}

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle;
- (void)movementWithDelta:(float)aDelta;

@end
