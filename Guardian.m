//
//  Guardian.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Guardian.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "Constants.h"


@implementation Guardian

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;
    if (zone == guardian_top || zone == guardian_bottom) {
        if (dx > 0 && pixelLocation.x > IPAD_WIDTH - 200) {
            dx = -dx;
        } else if (dx < 0 && pixelLocation.x < 200) {
            dx = -dx;
        }
    } else {
        if (dy > 0 && pixelLocation.y > IPAD_HEIGHT - 150) {
            dy = -dy;
        } else if (dy < 0 && pixelLocation.y < 150) {
            dy = -dy;
        }
    }

}

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 82;
        height = 41;
        float delay = 0.08f;
        int frames = 8;
        rotationAngle = angle;
        if (rotationAngle == 0.0f) {
            zone = guardian_bottom;
        } else if (rotationAngle == 90.0f) {
            zone = guardian_left;
        } else if (rotationAngle == 180.0f) {
            zone = guardian_top;
        } else if (rotationAngle == 270.0f) {
            zone = guardian_right;
        }

        seeking = [[Animation alloc] init];
        [self setupAnimation:seeking
                 spriteSheet:@"baddie-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:seeking
                 spriteSheet:@"baddie-2.png"
              animationDelay:delay numFrames:frames];

        delay = 0.1f;
        teleporting = [[Animation alloc] init];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-2.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-3.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-4.png"
              animationDelay:delay numFrames:frames];
        teleporting.type = kAnimationType_Once;

        animation = teleporting;
        state = EntityState_Transporting;
    }
    return self;
}

- (void)updateWithDelta:(float)aDelta {
    [animation updateWithDelta:aDelta];

    switch (state) {
        case EntityState_Transporting:
            if (animation.state == kAnimationState_Stopped) {
                state = EntityState_Alive;
                animation = seeking;
            }
            break;

        case EntityState_Alive:
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
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                       scale:Scale2fMake(1.0f, 1.0f)
                    rotation:rotationAngle];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [seeking release];
    [teleporting release];
    [super dealloc];
}

@end
