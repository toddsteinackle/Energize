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
#import "CubeStormAppDelegate.h"
#import "Primitives.h"


@implementation Cube

@synthesize collisionBox;

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 33;
        height = 33;

        float delay = 0.06f;
        int frames = 12;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"cube1.png" animationDelay:delay numFrames:frames];
        animation.type = kAnimationType_Once;
        state = EntityState_Alive;
        collisionWidth = appDelegate.widthScaleFactor * width *.9;
        collisionHeight = appDelegate.heightScaleFactor * height *.9;
        collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
        collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;

        collisionBox.x = pixelLocation.x - (appDelegate.widthScaleFactor * width / 2);
        collisionBox.y = pixelLocation.y - (appDelegate.heightScaleFactor * height / 2);
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {

    switch (state) {

        case EntityState_Alive:
            [animation updateWithDelta:aDelta];
            if (animation.currentFrame == 11) {
                animation.state = kAnimationState_Stopped;
                animation.currentFrame = 0;
                animation.state = kAnimationState_Running;
            }
            break;

        case EntityState_Idle:

            break;


        default:
            break;
    }
}

- (void)render {
#ifdef COLLISION_DEBUG
    // Debug code that allows us to draw bounding boxes for the entity
    // Draw the collision bounds in green
    glColor4f(0, 1, 0, 1);
    drawRect(CGRectMake(collisionBox.x + collisionXOffset, collisionBox.y + collisionYOffset,
                        collisionWidth, collisionHeight));
#endif
    switch (state) {

        case EntityState_Alive:
            [animation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                                       scale:Scale2fMake(scaleWidth, scaleHeight)
                                    rotation:rotationAngle];
            break;

        case EntityState_Idle:

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
