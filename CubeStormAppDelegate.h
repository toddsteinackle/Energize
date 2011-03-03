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

- (void)startAnimation;
- (void)stopAnimation;
- (void)gameLoop;
- (void)renderCurrentScene;
- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (void)authenticationChanged;

@end

