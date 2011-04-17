//
//  Asteroid.m
//  Energize
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Asteroid.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "EnergizeAppDelegate.h"


@implementation Asteroid

- (id)initLaunchLocationWithSpeed:(CGFloat)speed {
    width = 41;
    height = 41;
    self = [super initLaunchLocationWithSpeed:speed];
    if (self != nil) {
        float delay = 0.08f;
        frames = 24;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"asteroid.png" animationDelay:delay numFrames:frames];

        collisionWidth = appDelegate.widthScaleFactor * width *.8;
        collisionHeight = appDelegate.heightScaleFactor * height *.8;
        collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
        collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;
    }
    return self;
}

@end
