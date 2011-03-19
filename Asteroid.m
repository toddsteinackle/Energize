//
//  Asteroid.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Asteroid.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"


@implementation Asteroid

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 41;
        height = 41;

        float delay = 0.08f;
        int frames = 24;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"asteroid.png" animationDelay:delay numFrames:frames];
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
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
