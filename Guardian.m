//
//  Guardian.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "Guardian.h"
#import "GLView.h"
#import "SoundManager.h"
#import "Animation.h"
#import "CubeStormAppDelegate.h"
#import "Fireball.h"
#import "Global.h"

@implementation Guardian

@synthesize fireballs;
@synthesize firingTimer;

- (void)movementWithDelta:(float)aDelta {
    pixelLocation.x += dx * aDelta;
    pixelLocation.y += dy * aDelta;

    switch (zone) {
        case guardian_top:
            if (dx > 0 && pixelLocation.x > appDelegate.GUARDIAN_RIGHT_BOUND) {
                dx = -dx;
            } else if (dx < 0 && pixelLocation.x < appDelegate.GUARDIAN_LEFT_BOUND + appDelegate.GUARDIAN_WIDTH) {
                dx = -dx;
            }
            break;
        case guardian_bottom:
            if (dx < 0 && pixelLocation.x < appDelegate.GUARDIAN_LEFT_BOUND) {
                dx = -dx;
            } else if (dx > 0 && pixelLocation.x > appDelegate.GUARDIAN_RIGHT_BOUND - appDelegate.GUARDIAN_WIDTH) {
                dx = -dx;
            }
            break;
        case guardian_left:
            if (dy > 0 && pixelLocation.y > appDelegate.GUARDIAN_TOP_BOUND) {
                dy = -dy;
            } else if (dy < 0 && pixelLocation.y < appDelegate.GUARDIAN_BOTTOM_BOUND + appDelegate.GUARDIAN_WIDTH) {
                dy = -dy;
            }
            break;
        case guardian_right:
            if (dy < 0 && pixelLocation.y < appDelegate.GUARDIAN_BOTTOM_BOUND) {
                dy = -dy;
            } else if (dy > 0 && pixelLocation.y > appDelegate.GUARDIAN_TOP_BOUND - appDelegate.GUARDIAN_WIDTH) {
                dy = -dy;
            }
            break;

        default:
            break;
    }

}

- (id)initWithPixelLocation:(CGPoint)aLocation andRotation:(float)angle {
    self = [super initWithPixelLocation:aLocation];
    if (self != nil) {
        width = 82;
        height = 41;
        float delay = 0.04f;
        int frames = 8;
        rotationAngle = angle;
        if (rotationAngle == 0.0f) {
            zone = guardian_bottom;
        } else if (rotationAngle == 90.0f) {
            zone = guardian_right;
        } else if (rotationAngle == 180.0f) {
            zone = guardian_top;
        } else if (rotationAngle == 270.0f) {
            zone = guardian_left;
        }

        firing = [[Animation alloc] init];
        [self setupAnimation:firing
                 spriteSheet:@"baddie-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:firing
                 spriteSheet:@"baddie-2.png"
              animationDelay:delay numFrames:frames];
        firing.type = kAnimationType_Repeating;
        firing.state = kAnimationState_Stopped;

        delay = 0.06f;
        teleporting = [[Animation alloc] init];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-1.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-2.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-3.png"
              animationDelay:delay numFrames:frames];
        [self setupAnimation:teleporting
                 spriteSheet:@"baddie-teleport-4.png"
              animationDelay:delay numFrames:frames];
        teleporting.type = kAnimationType_Once;

        animation = teleporting;
        state = EntityState_Transporting;

#pragma mark -
#pragma mark firing init

        firingTimer = 0;
        fireball_counter = 0;
        justFired = launchingTwoFireballs = FALSE;
        fireballs = [[NSMutableArray alloc] init];
        numberOfFireballs = 20;
        for (int i = 0; i < numberOfFireballs; ++i) {
            Fireball *f = [[Fireball alloc] initWithPixelLocation:CGPointMake(0, 0)];
            [fireballs addObject:f];
            [f release];
        }
    }

    switch (appDelegate.glView.currentLevel) {
        case 0:
        case 1:
            baseFireDelay =  5;
            chanceFor2Fireballs = 2000;
            fireDelay = (arc4random() % baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
            break;
        default:
            break;

    }
#ifdef FIRING_DEBUG
    NSLog(@"firing init");
    NSLog(@"base: %i", baseFireDelay);
    NSLog(@"fireDelay: %f", fireDelay);
#endif

    return self;
}

- (void)updateWithDelta:(float)aDelta {
    [animation updateWithDelta:aDelta];

    switch (state) {
        case EntityState_Transporting:
            if (animation.state == kAnimationState_Stopped) {
                state = EntityState_Alive;
                animation = firing;
            }
            break;

        case EntityState_Alive:
            [self movementWithDelta:aDelta];

            // the starting and stopping of the animation drives the firing
            if (animation.currentFrame == 15) {
                animation.state = kAnimationState_Stopped;
                animation.currentFrame = 0;
                launchingTwoFireballs = justFired = FALSE;
            }

            firingTimer += aDelta;
            if (firingTimer > fireDelay) {
                fireDelay = (arc4random() % baseFireDelay + 1) + RANDOM_MINUS_1_TO_1();
#ifdef FIRING_DEBUG
                switch (zone) {
                    case guardian_top:
                        NSLog(@"guardian_top firing");
                        NSLog(@"base: %i", baseFireDelay);
                        NSLog(@"fire delay: %f", fireDelay);
                        break;
                    case guardian_bottom:
                        NSLog(@"guardian_bottom firing");
                        NSLog(@"base: %i", baseFireDelay);
                        NSLog(@"fire delay: %f", fireDelay);
                        break;
                    case guardian_left:
                        NSLog(@"guardian_left firing");
                        NSLog(@"base: %i", baseFireDelay);
                        NSLog(@"fire delay: %f", fireDelay);
                        break;
                    case guardian_right:
                        NSLog(@"guardian_right firing");
                        NSLog(@"base: %i", baseFireDelay);
                        NSLog(@"fire delay: %f", fireDelay);
                        break;

                    default:
                        break;
                }
#endif
                animation.state = kAnimationState_Running;
                firingTimer = 0;
            }

            if (!launchingTwoFireballs) {
                if (1 == (arc4random() % chanceFor2Fireballs + 1)) {
                    launchingTwoFireballs = TRUE;
                }
            }
            if (launchingTwoFireballs) {
                if (animation.state == kAnimationState_Running && (animation.currentFrame > 7)) {
                    if (animation.currentFrame == 14) {
                        justFired = FALSE;
                    }
                    if (!justFired) {
                        [self fire];
                        justFired = TRUE;
                    }
                }
            } else {
                if (animation.state == kAnimationState_Running && animation.currentFrame == 14) {
                    if (!justFired) {
                        [self fire];
                        justFired = TRUE;
                    }
                }
            }

            break;

        default:
            break;
    }
}

- (void)fire {
    Fireball *f = [fireballs objectAtIndex:fireball_counter];
    if (f.state == EntityState_Alive) {
        f = [[Fireball alloc] initWithPixelLocation:CGPointMake(0, 0)];
        [fireballs addObject:f];
        [f release];
#ifdef GAMEPLAY_DEBUG
        NSLog(@"fireball_counter: %i", fireball_counter);
        NSLog(@"Attempt to launch fireball while still active from previous launch.");
        NSLog(@"allocating new fireball, fireballs count now: %i", [fireballs count]);
#endif
    }
    f.state = EntityState_Alive;
    switch (zone) {
        case guardian_top:
            f.dx = 0;
            f.dy = -appDelegate.FIREBALL_SPEED_VERTICAL;
            f.pixelLocation = CGPointMake(pixelLocation.x - (appDelegate.GUARDIAN_WIDTH/2) - (31/2 * appDelegate.widthScaleFactor),
                                          pixelLocation.y - (appDelegate.GUARDIAN_HEIGHT) - (31/2 * appDelegate.heightScaleFactor));
            break;
        case guardian_bottom:
            f.dx = 0;
            f.dy = appDelegate.FIREBALL_SPEED_VERTICAL;
            f.pixelLocation = CGPointMake(pixelLocation.x + (appDelegate.GUARDIAN_WIDTH / 2 - 31/2 * appDelegate.widthScaleFactor),
                                          pixelLocation.y + (appDelegate.GUARDIAN_HEIGHT - 31 * appDelegate.heightScaleFactor));
            break;
        case guardian_left:
            f.dx = appDelegate.FIREBALL_SPEED_HORIZONTAL;
            f.dy = 0;
            f.pixelLocation = CGPointMake(pixelLocation.x + (31/2 * appDelegate.widthScaleFactor),
                                          pixelLocation.y - (appDelegate.GUARDIAN_WIDTH/2)-(31/2 * appDelegate.heightScaleFactor));
            break;
        case guardian_right:
            f.dx = -appDelegate.FIREBALL_SPEED_HORIZONTAL;
            f.dy = 0;
            f.pixelLocation = CGPointMake(pixelLocation.x - (appDelegate.GUARDIAN_HEIGHT + 31/2 * appDelegate.widthScaleFactor),
                                          pixelLocation.y + (appDelegate.GUARDIAN_WIDTH/2)-(31/2 * appDelegate.heightScaleFactor));
            break;
        default:
            break;
    }
    if (++fireball_counter == [fireballs count]) {
        fireball_counter = 0;
    }
}

- (void)render {
#ifdef COLLISION_DEBUG
    [super render];
#endif
    [animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)
                       scale:Scale2fMake(scaleWidth, scaleHeight)
                    rotation:rotationAngle];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)otherEntity {

}

- (void)dealloc {
    [firing release];
    [teleporting release];
    [fireballs release];
    [super dealloc];
}

@end
