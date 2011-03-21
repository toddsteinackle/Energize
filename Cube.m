//
//  Cube.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Cube.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"


@implementation Cube

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 33;
        height = 33;

        float delay = 0.05f;
        int frames = 15;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"boxes.png" animationDelay:delay numFrames:frames];
        animation.type = kAnimationType_Once;
        state = EntityState_Alive;
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    [animation updateWithDelta:aDelta];

    switch (state) {

        case EntityState_Alive:
            if (animation.currentFrame == 14) {
                animation.state = kAnimationState_Stopped;
                animation.currentFrame = 0;
                animation.state = kAnimationState_Running;
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
    [animation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                       scale:Scale2fMake(scaleWidth, scaleHeight)
                    rotation:rotationAngle];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
