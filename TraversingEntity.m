//
//  TraversingEntity.m
//  Energize
//
//  Created by Todd Steinackle on 4/5/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "TraversingEntity.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "EnergizeAppDelegate.h"


@implementation TraversingEntity

- (id)initLaunchLocationWithSpeed:(CGFloat)speed {
    self = [super initWithPixelLocation:CGPointMake(0, 0)];
    if (self != nil) {
        int drift = 40;
        int diagonalDrift = 20;
        switch (arc4random() % 8 + 1) {
            case 1:
                launch_location = te_top;
                pixelLocation.x = appDelegate.SCREEN_WIDTH / 2;
                pixelLocation.y = appDelegate.SCREEN_HEIGHT;
                dx = (arc4random() % drift + 1) * appDelegate.widthScaleFactor;
                if (1 == (arc4random() % 2 + 1)) {
                    dx = -dx;
                }
                dy = -speed * appDelegate.heightScaleFactor;
                break;
            case 2:
                launch_location = te_right;
                pixelLocation.x = appDelegate.SCREEN_WIDTH;
                pixelLocation.y = appDelegate.SCREEN_HEIGHT / 2;
                dy = (arc4random() % drift + 1) * appDelegate.heightScaleFactor;
                if (1 == (arc4random() % 2 + 1)) {
                    dy = -dy;
                }
                dx = -speed * appDelegate.widthScaleFactor;
                break;
            case 3:
                launch_location = te_bottom;
                pixelLocation.x = appDelegate.SCREEN_WIDTH / 2;
                pixelLocation.y = 0 - height * appDelegate.heightScaleFactor;
                dx = (arc4random() % drift + 1) * appDelegate.widthScaleFactor;
                if (1 == (arc4random() % 2 + 1)) {
                    dx = -dx;
                }
                dy = speed * appDelegate.heightScaleFactor;
                break;
            case 4:
                launch_location = te_left;
                pixelLocation.x = 0 - width * appDelegate.widthScaleFactor;
                pixelLocation.y = appDelegate.SCREEN_HEIGHT / 2;
                dy = (arc4random() % drift + 1) * appDelegate.heightScaleFactor;
                if (1 == (arc4random() % 2 + 1)) {
                    dy = -dy;
                }
                dx = speed * appDelegate.widthScaleFactor;
                break;
            case 5:
                launch_location = te_top_left;
                pixelLocation.x = 0 - width * appDelegate.widthScaleFactor;
                pixelLocation.y = appDelegate.SCREEN_HEIGHT;
                dy = ((arc4random() % drift + 1) + diagonalDrift) * appDelegate.heightScaleFactor;
                dy = -dy;
                dx = speed * appDelegate.widthScaleFactor;
                break;
            case 6:
                launch_location = te_top_right;
                pixelLocation.x = appDelegate.SCREEN_WIDTH;
                pixelLocation.y = appDelegate.SCREEN_HEIGHT + height * appDelegate.heightScaleFactor;
                dy = ((arc4random() % drift + 1) + diagonalDrift) * appDelegate.heightScaleFactor;
                dy = -dy;
                dx = speed * appDelegate.widthScaleFactor;
                dx = -dx;
                break;
            case 7:
                launch_location = te_bottom_right;
                pixelLocation.x = appDelegate.SCREEN_WIDTH;
                pixelLocation.y = 0 - height * appDelegate.heightScaleFactor;
                dy = ((arc4random() % drift + 1) + diagonalDrift) * appDelegate.heightScaleFactor;
                dx = speed * appDelegate.widthScaleFactor;
                dx = -dx;
                break;
            case 8:
                launch_location = te_bottom_left;
                pixelLocation.x = 0 - width * appDelegate.widthScaleFactor;
                pixelLocation.y = 0 - height * appDelegate.heightScaleFactor;
                dy = ((arc4random() % drift + 1) + diagonalDrift) * appDelegate.heightScaleFactor;
                dx = speed * appDelegate.widthScaleFactor;
                break;

            default:
                break;
        }

        state = EntityState_Idle;
    }
    return self;
}

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    switch (launch_location) {
        case te_top:
            if (pixelLocation.y < 0 || pixelLocation.x < 0 || pixelLocation.x > appDelegate.SCREEN_WIDTH) {
                state = EntityState_Idle;
            }
            break;
        case te_right:
            if (pixelLocation.x < 0 || pixelLocation.y > appDelegate.SCREEN_HEIGHT || pixelLocation.y < 0) {
                state = EntityState_Idle;
            }
            break;
        case te_bottom:
            if (pixelLocation.y > appDelegate.SCREEN_HEIGHT || pixelLocation.x < 0 || pixelLocation.x > appDelegate.SCREEN_WIDTH) {
                state = EntityState_Idle;
            }
            break;
        case te_left:
            if (pixelLocation.x > appDelegate.SCREEN_WIDTH || pixelLocation.y > appDelegate.SCREEN_HEIGHT || pixelLocation.y < 0) {
                state = EntityState_Idle;
            }
            break;
        case te_top_left:
            if (pixelLocation.y < 0 || pixelLocation.x > appDelegate.SCREEN_WIDTH) {
                state = EntityState_Idle;
            }
            break;
        case te_top_right:
            if (pixelLocation.x < 0 || pixelLocation.y < 0) {
                state = EntityState_Idle;
            }
            break;
        case te_bottom_right:
            if (pixelLocation.y > appDelegate.SCREEN_HEIGHT || pixelLocation.x < 0) {
                state = EntityState_Idle;
            }
            break;
        case te_bottom_left:
            if (pixelLocation.y > appDelegate.SCREEN_HEIGHT || pixelLocation.x > appDelegate.SCREEN_WIDTH) {
                state = EntityState_Idle;
            }
            break;

        default:
            break;
    }
}

- (void)updateWithDelta:(float)aDelta {
    switch (state) {
        case EntityState_Alive:
            [animation updateWithDelta:aDelta];
            if (animation.currentFrame == frames-1) {
                animation.state = kAnimationState_Stopped;
                animation.currentFrame = 0;
                animation.state = kAnimationState_Running;
            }
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

- (void)dealloc {
    [animation release];
    [super dealloc];
}

@end
