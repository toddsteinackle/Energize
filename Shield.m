//
//  Shield.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/26/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Shield.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"


@implementation Shield

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 41;
        height = 41;

        animation = [[Animation alloc] init];
        float delay = 0.3;
        int frames = 4;
        [self setupAnimation:animation
                 spriteSheet:@"bonus-shield.png"
              animationDelay:delay numFrames:frames];
        animation.type = kAnimationType_Once;
        animation.state = kAnimationState_Stopped;
        state = EntityState_Idle;
    }
    return self;
}

- (void)updateWithDelta:(float)aDelta {
    switch (state) {
        case EntityState_Alive:
            [animation updateWithDelta:aDelta];
            if (animation.state == kAnimationState_Stopped) {
                state = EntityState_Idle;
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
        case EntityState_Alive:
            [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                               scale:Scale2fMake(scaleWidth, scaleHeight)
                            rotation:rotationAngle];
            break;
        default:
            break;
    }
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
