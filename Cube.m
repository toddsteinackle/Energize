//
//  Cube.m
//  Energize
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Cube.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "EnergizeAppDelegate.h"
#import "Primitives.h"
#import "ParticleEmitter.h"


@implementation Cube

@synthesize isDoubleCube;

- (id)initWithPixelLocation:(CGPoint)aLocation andAppearingDelay:(float)apDelay isDoubleCube:(BOOL)DoubleCube {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 33;
        height = 33;

        float delay = 0.07f;
        int frames = 12;
        singleCube = [[Animation alloc] init];
        doubleCube = [[Animation alloc] init];
        if (1 == (arc4random() % 2 + 1)) {
            [self setupAnimation:singleCube spriteSheet:@"cube_purple.png" animationDelay:delay numFrames:frames];
            [self setupAnimation:doubleCube spriteSheet:@"cube_red.png" animationDelay:delay numFrames:frames];
        } else {
            [self setupAnimation:singleCube spriteSheet:@"cube_purple_reverse.png" animationDelay:delay numFrames:frames];
            [self setupAnimation:doubleCube spriteSheet:@"cube_red_reverse.png" animationDelay:delay numFrames:frames];
        }
        if (DoubleCube) {
            animation = doubleCube;
        } else {
            animation = singleCube;
        }
        animation.type = kAnimationType_Once;
        state = EntityState_Idle;
        collisionWidth = appDelegate.widthScaleFactor * width *.9;
        collisionHeight = appDelegate.heightScaleFactor * height *.9;
        collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
        collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;

        collisionBox.x = pixelLocation.x - (appDelegate.widthScaleFactor * width / 2);
        collisionBox.y = pixelLocation.y - (appDelegate.heightScaleFactor * height / 2);
        appearingDelay = apDelay;
        appearingTimer = 0;
        isDoubleCube = DoubleCube;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            dyingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"cube_dying_ipad.pex"];
        } else {
            if (appDelegate.retinaDisplay) {
                dyingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"cube_dying_retina.pex"];
            } else {
                dyingEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"cube_dying_iphone.pex"];
            }
        }
    }
    return self;
}

- (void)changeAnimation {
    singleCube.currentFrame = doubleCube.currentFrame;
    singleCube.state = EntityState_Alive;
    animation = singleCube;
    animation.state = kAnimationState_Running;
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
            appearingTimer += aDelta;
            if (appearingTimer > appearingDelay) {
                state = EntityState_Alive;
                appearingTimer = 0;
            }
            break;
        case EntityState_Dead:
            [dyingEmitter updateWithDelta:aDelta];
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
        case EntityState_Dead:
            [dyingEmitter renderParticles];
            break;

        default:
            break;
    }
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [singleCube release];
    [doubleCube release];
    [dyingEmitter release];
    [super dealloc];
}

@end
