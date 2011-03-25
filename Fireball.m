//
//  Fireball.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Fireball.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "CubeStormAppDelegate.h"


@implementation Fireball

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 31;
        height = 31;

        float delay = 0.1f;
        int frames = 8;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"fire.png" animationDelay:delay numFrames:frames];
        state = EntityState_Idle;

        collisionWidth = appDelegate.widthScaleFactor * width;
        collisionHeight = appDelegate.heightScaleFactor * height;
        collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
        collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;
    }
    return self;
}

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    if (dx > 0 && pixelLocation.x > appDelegate.SCREEN_WIDTH) {
        state = EntityState_Idle;
        return;
    }
    if (dx < 0 && pixelLocation.x < 0) {
        state = EntityState_Idle;
        return;
    }
    if (dy > 0 && pixelLocation.y > appDelegate.SCREEN_HEIGHT) {
        state = EntityState_Idle;
        return;
    }
    if (dy < 0 && pixelLocation.y < 0) {
        state = EntityState_Idle;
        return;
    }
}

- (void)updateWithDelta:(GLfloat)aDelta {
    switch (state) {
        case EntityState_Alive:
            [animation updateWithDelta:aDelta];
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
