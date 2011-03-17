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


@implementation Guardian

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 82;
        height = 41;
        float delay = 0.08;
        int frames = 8;
        rotationAngle = angle;

        normalAnimation = [[Animation alloc] init];
        [self setupAnimation:normalAnimation
                 spriteSheet:@"baddie-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:normalAnimation
                 spriteSheet:@"baddie-2.png"
              animationDelay:delay numFrames:frames];

        delay = 0.1;
        teleportingAnimation = [[Animation alloc] init];
        [self setupAnimation:teleportingAnimation
                 spriteSheet:@"baddie-teleport-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleportingAnimation
                 spriteSheet:@"baddie-teleport-2.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleportingAnimation
                 spriteSheet:@"baddie-teleport-3.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleportingAnimation
                 spriteSheet:@"baddie-teleport-4.png"
              animationDelay:delay numFrames:frames];
        teleportingAnimation.type = kAnimationType_Once;

        animation = teleportingAnimation;
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    [animation updateWithDelta:aDelta];
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
    [normalAnimation release];
    [teleportingAnimation release];
    [super dealloc];
}

@end
