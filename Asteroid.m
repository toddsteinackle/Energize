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
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"


@implementation Asteroid

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 39;
        height = 39;
        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                       controlFile:@"pss"
                                                                       imageFilter:GL_LINEAR];
        Image *SpriteSheetImage = [pss imageForKey:@"asteroid.png"];

        spriteSheet = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                               sheetKey:@"asteroid.png"
                                             spriteSize:CGSizeMake(width, height)
                                                spacing:2
                                                 margin:0];

        animation = [[Animation alloc] init];
        float delay = 0.08;
        int numImages = 23;
        for (int i = 0; i < numImages; ++i) {
            [animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(i, 0)] delay:delay];
        }

        animation.state = kAnimationState_Running;
        animation.type = kAnimationType_Repeating;
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
