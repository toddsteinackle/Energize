//
//  Explosion.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Explosion.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"


@implementation Explosion

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 85;
        height = 85;

        float delay = 0.05f;
        int frames = 8;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"explosion1.png" animationDelay:delay numFrames:frames];
        [self setupAnimation:animation spriteSheet:@"explosion2.png" animationDelay:delay numFrames:frames];
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
