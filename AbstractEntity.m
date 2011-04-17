//
//  AbstractEntity.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Primitives.h"
#import "AbstractEntity.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "PackedSpriteSheet.h"
#import "EnergizeAppDelegate.h"

@implementation AbstractEntity

@synthesize state;
@synthesize image;
@synthesize pixelLocation;
@synthesize dx;
@synthesize dy;
@synthesize collisionWidth;
@synthesize collisionHeight;
@synthesize collisionXOffset;
@synthesize collisionYOffset;
@synthesize scaleFactor;
@synthesize width;
@synthesize appearingEmitter;
@synthesize dyingEmitter;
@synthesize middleX;
@synthesize middleY;
@synthesize animation;
@synthesize collisionBox;

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super init];
    if (self != nil) {
        sharedSoundManager = [SoundManager sharedSoundManager];
        appDelegate = (EnergizeAppDelegate *)[[UIApplication sharedApplication] delegate];
        pixelLocation.x = aLocation.x;
        pixelLocation.y = aLocation.y;
        scaleWidth = appDelegate.widthScaleFactor;
        scaleHeight = appDelegate.heightScaleFactor;
        rotationAngle = 0.0f;
    }
    return self;
}

- (id)initWithPixelLocation:(CGPoint)aLocation andAppearingDelay:(float)apDelay { return self; }

- (void)setupAnimation:(Animation*)anim
           spriteSheet:(NSString*)aSpriteSheet
        animationDelay:(float)delay
             numFrames:(int)frames {

    PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                   controlFile:@"pss"
                                                                   imageFilter:GL_LINEAR];

    Image *SpriteSheetImage = [pss imageForKey:aSpriteSheet];

    spriteSheet = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                          sheetKey:aSpriteSheet
                                        spriteSize:CGSizeMake(width, height)
                                           spacing:0
                                            margin:0];
    for (int i = 0; i < frames; ++i) {
        [anim addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(i, 0)] delay:delay];
    }
    anim.state = kAnimationState_Running;
    anim.type = kAnimationType_Repeating;

}

- (void)setupVerticalAnimation:(Animation*)anim
           spriteSheet:(NSString*)aSpriteSheet
        animationDelay:(float)delay
             numFrames:(int)frames {

    PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pss.png"
                                                                   controlFile:@"pss"
                                                                   imageFilter:GL_LINEAR];

    Image *SpriteSheetImage = [pss imageForKey:aSpriteSheet];

    spriteSheet = [SpriteSheet spriteSheetForImage:SpriteSheetImage
                                          sheetKey:aSpriteSheet
                                        spriteSize:CGSizeMake(width, height)
                                           spacing:0
                                            margin:0];
    for (int i = 0; i < frames; ++i) {
        [anim addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, i)] delay:delay];
    }
    anim.state = kAnimationState_Running;
    anim.type = kAnimationType_Repeating;

}

#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(float)aDelta { }

#pragma mark -
#pragma mark Rendering

- (void)render {
    // Debug code that allows us to draw bounding boxes for the entity
    // Draw the collision bounds in green
    glColor4f(0, 1, 0, 1);
    drawRect(CGRectMake(pixelLocation.x + collisionXOffset, pixelLocation.y + collisionYOffset,
                        collisionWidth, collisionHeight));
}

#pragma mark -
#pragma mark Collision

- (void)checkForCollisionWithEntity:(AbstractEntity*)otherEntity { }

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

}

@end
