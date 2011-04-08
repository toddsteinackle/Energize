//
//  PowerUpShields.m
//  CubeStorm
//
//  Created by Todd Steinackle on 4/8/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "PowerUpShields.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "CubeStormAppDelegate.h"


@implementation PowerUpShields

- (id)initLaunchLocationWithSpeed:(CGFloat)speed {
    width = 25;
    height = 25;
    self = [super initLaunchLocationWithSpeed:speed];
    if (self != nil) {
        float delay = 0.09f;
        frames = 27;
        animation = [[Animation alloc] init];
        [self setupAnimation:animation spriteSheet:@"power_up_shields.png" animationDelay:delay numFrames:frames];

        collisionWidth = appDelegate.widthScaleFactor * width * .65;
        collisionHeight = appDelegate.heightScaleFactor * height * .65;
        collisionXOffset = ((appDelegate.widthScaleFactor * width) - collisionWidth) / 2;
        collisionYOffset = ((appDelegate.heightScaleFactor * height) - collisionHeight) / 2;
    }
    return self;
}

@end
