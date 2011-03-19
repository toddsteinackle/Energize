//
//  CubeStormAppDelegate.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CubeStormViewController;

@interface CubeStormAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CubeStormViewController *viewController;
    UIViewController *currentViewController;
    BOOL gameCenterAvailable;
    BOOL ios4orGreater;

    CGFloat SCREEN_HEIGHT;
    CGFloat SCREEN_WIDTH;

    CGFloat GUARDIAN_WIDTH;
    CGFloat GUARDIAN_HEIGHT;
    CGFloat GUARDIAN_RIGHT_BASE;
    CGFloat GUARDIAN_LEFT_BASE;
    CGFloat GUARDIAN_TOP_BASE;
    CGFloat GUARDIAN_BOTTOM_BASE;
    CGFloat GUARDIAN_LEFT_BOUND;
    CGFloat GUARDIAN_RIGHT_BOUND;
    CGFloat GUARDIAN_TOP_BOUND;
    CGFloat GUARDIAN_BOTTOM_BOUND;
    CGFloat GUARDIAN_SPEED_HORIZONTAL;
    CGFloat GUARDIAN_SPEED_VERTICAL;

    CGFloat SHIP_WIDTH;
    CGFloat SHIP_HEIGHT;
    CGFloat SHIP_SPEED_HORIZONTAL;
    CGFloat SHIP_SPEED_VERTICAL;
    CGFloat SHIP_TURBO_SPEED_HORIZONTAL;
    CGFloat SHIP_TURBO_SPEED_VERTICAL;
    CGFloat SHIP_LEFT_BOUND;
    CGFloat SHIP_RIGHT_BOUND;
    CGFloat SHIP_TOP_BOUND;
    CGFloat SHIP_BOTTOM_BOUND;

    float widthScaleFactor;
    float heightScaleFactor;


#ifdef FRAME_COUNTER
    CFTimeInterval m_FPS_lastSecondStart;
    int m_FPS_framesThisSecond;
    int m_FPS;
#endif

@private
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
    CFTimeInterval lastTime;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CubeStormViewController *viewController;
@property (nonatomic, retain) IBOutlet UIViewController *currentViewController;
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (readonly, nonatomic) BOOL gameCenterAvailable;
@property (readonly, nonatomic) BOOL ios4orGreater;

@property (readonly, nonatomic) CGFloat SCREEN_HEIGHT;
@property (readonly, nonatomic) CGFloat SCREEN_WIDTH;

@property (readonly, nonatomic) CGFloat GUARDIAN_WIDTH;
@property (readonly, nonatomic) CGFloat GUARDIAN_HEIGHT;
@property (readonly, nonatomic) CGFloat GUARDIAN_RIGHT_BASE;
@property (readonly, nonatomic) CGFloat GUARDIAN_LEFT_BASE;
@property (readonly, nonatomic) CGFloat GUARDIAN_TOP_BASE;
@property (readonly, nonatomic) CGFloat GUARDIAN_BOTTOM_BASE;
@property (readonly, nonatomic) CGFloat GUARDIAN_LEFT_BOUND;
@property (readonly, nonatomic) CGFloat GUARDIAN_RIGHT_BOUND;
@property (readonly, nonatomic) CGFloat GUARDIAN_TOP_BOUND;
@property (readonly, nonatomic) CGFloat GUARDIAN_BOTTOM_BOUND;
@property (readonly, nonatomic) CGFloat GUARDIAN_SPEED_HORIZONTAL;
@property (readonly, nonatomic) CGFloat GUARDIAN_SPEED_VERTICAL;

@property (readonly, nonatomic) CGFloat SHIP_WIDTH;
@property (readonly, nonatomic) CGFloat SHIP_HEIGHT;
@property (readonly, nonatomic) CGFloat SHIP_SPEED_HORIZONTAL;
@property (readonly, nonatomic) CGFloat SHIP_SPEED_VERTICAL;
@property (readonly, nonatomic) CGFloat SHIP_TURBO_SPEED_HORIZONTAL;
@property (readonly, nonatomic) CGFloat SHIP_TURBO_SPEED_VERTICAL;
@property (readonly, nonatomic) CGFloat SHIP_LEFT_BOUND;
@property (readonly, nonatomic) CGFloat SHIP_RIGHT_BOUND;
@property (readonly, nonatomic) CGFloat SHIP_TOP_BOUND;
@property (readonly, nonatomic) CGFloat SHIP_BOTTOM_BOUND;

@property (readonly, nonatomic) float widthScaleFactor;
@property (readonly, nonatomic) float heightScaleFactor;

- (void)startAnimation;
- (void)stopAnimation;
- (void)gameLoop;
- (void)renderCurrentScene;
- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (void)authenticationChanged;

@end

