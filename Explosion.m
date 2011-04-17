//
//  Explosion.m
//  Energize
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Explosion.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "EnergizeAppDelegate.h"


@implementation Explosion

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 61;
        height = 61;

        float delay = 0.05f;
        int frames = 16;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"explosion.png" animationDelay:delay numFrames:frames];
        animation.type = kAnimationType_Once;
        animation.state = kAnimationState_Stopped;
        state = EntityState_Idle;
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
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
