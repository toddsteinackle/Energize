//
//  AbstractEntity.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Primitives.h"
#import "AbstractEntity.h"
#import "SoundManager.h"

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

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithPixelLocation:(CGPoint)aLocation {
    self = [super init];
    if (self != nil) {
        sharedSoundManager = [SoundManager sharedSoundManager];
        appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];
        pixelLocation.x = aLocation.x;
        pixelLocation.y = aLocation.y;
    }
    return self;
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
    drawRect(CGRectMake(pixelLocation.x - collisionXOffset, pixelLocation.y - collisionYOffset,
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
