//
//  Ship.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Ship.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"


@implementation Ship

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 41;
        height = 41;

        teleporting = [[Animation alloc] init];
        float delay = 0.1;
        int frames = 24;
        [self setupAnimation:teleporting
                 spriteSheet:@"ship-teleport.png"
              animationDelay:delay numFrames:frames];

        frames = 4;
        up = [[Animation alloc] init];
        [self setupAnimation:up spriteSheet:@"ship-up-boost1.png" animationDelay:delay numFrames:frames];

        upThrust = [[Animation alloc] init];
        [self setupAnimation:upThrust spriteSheet:@"ship-up-boost2.png" animationDelay:delay numFrames:frames];

        down = [[Animation alloc] init];
        [self setupAnimation:down spriteSheet:@"ship-down-boost1.png" animationDelay:delay numFrames:frames];

        downThrust = [[Animation alloc] init];
        [self setupAnimation:downThrust spriteSheet:@"ship-down-boost2.png" animationDelay:delay numFrames:frames];

        right = [[Animation alloc] init];
        [self setupVerticalAnimation:right spriteSheet:@"ship-right-boost1.png"
                      animationDelay:delay numFrames:frames];

        rightThrust = [[Animation alloc] init];
        [self setupVerticalAnimation:rightThrust spriteSheet:@"ship-right-boost2.png"
                      animationDelay:delay numFrames:frames];

        left = [[Animation alloc] init];
        [self setupVerticalAnimation:left spriteSheet:@"ship-left-boost1.png"
                      animationDelay:delay numFrames:frames];

        leftThrust = [[Animation alloc] init];
        [self setupVerticalAnimation:leftThrust spriteSheet:@"ship-left-boost2.png"
                      animationDelay:delay numFrames:frames];

        frames = 12;
        width = 61;
        delay = 0.075;
        warp = [[Animation alloc] init];
        [self setupAnimation:warp
                 spriteSheet:@"ship-warp.png"
              animationDelay:delay numFrames:frames];

    }
    animation = leftThrust;
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    [animation updateWithDelta:aDelta];
}

- (void)render {
#ifdef COLLISION_DEBUG
    [super render];
#endif
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
