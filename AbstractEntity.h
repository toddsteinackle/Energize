//
//  AbstractEntity.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

@class Image;
@class SpriteSheet;
@class Animation;
@class ParticleEmitter;
@class SoundManager;
@class CubeStormAppDelegate;

typedef enum {
    EntityState_Idle,
    EntityState_Transporting,
    EntityState_Alive,
} EntityState;

@interface AbstractEntity : NSObject <NSCoding> {

    CubeStormAppDelegate *appDelegate;
    SoundManager *sharedSoundManager;
    Image *image;
    SpriteSheet *spriteSheet;
    Animation *animation;
    CGPoint pixelLocation;
    ParticleEmitter *dyingEmitter;
    ParticleEmitter *appearingEmitter;
    EntityState state;

    CGFloat dx, dy;
    CGFloat collisionWidth, collisionHeight, collisionXOffset, collisionYOffset;
    CGFloat height, width;
    CGFloat scaleFactor;
    CGFloat middleX;
    CGFloat middleY;
}

@property (nonatomic, readonly) Image *image;
@property (nonatomic, assign) CGPoint pixelLocation;
@property (nonatomic, assign) EntityState state;
@property (nonatomic, assign) CGFloat dx;
@property (nonatomic, assign) CGFloat dy;
@property (nonatomic, assign) CGFloat collisionWidth;
@property (nonatomic, assign) CGFloat collisionHeight;
@property (nonatomic, assign) CGFloat collisionXOffset;
@property (nonatomic, assign) CGFloat collisionYOffset;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, readonly) ParticleEmitter *dyingEmitter;
@property (nonatomic, readonly) ParticleEmitter *appearingEmitter;
@property (nonatomic, assign) CGFloat middleX;
@property (nonatomic, assign) CGFloat middleY;
@property (nonatomic, readonly) Animation *animation;


- (id)initWithPixelLocation:(CGPoint)aLocation;
- (void)updateWithDelta:(float)aDelta;
- (void)render;
- (void)checkForCollisionWithEntity:(AbstractEntity*)otherEntity;
- (void)setupAnimation:(Animation*)anim
           spriteSheet:(NSString*)aSpriteSheet
        animationDelay:(float)delay
             numFrames:(int)frames;
- (void)setupVerticalAnimation:(Animation*)anim
           spriteSheet:(NSString*)aSpriteSheet
        animationDelay:(float)delay
             numFrames:(int)frames;

@end
