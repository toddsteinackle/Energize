//
//  EnergizeAppDelegate.h
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EnergizeViewController;
@class GLView;
@class SoundManager;
@class GKScore;
@class GKAchievement;

@interface EnergizeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EnergizeViewController *viewController;
    UIViewController *currentViewController;
    GLView *glView;
    SoundManager *sharedSoundManager;
    BOOL gameCenterAvailable;
    BOOL ios4orGreater;
    BOOL retinaDisplay;

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

    CGFloat FIREBALL_SPEED_HORIZONTAL;
    CGFloat FIREBALL_SPEED_VERTICAL;

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
    CGFloat SHIP_STARTING_X_OFFSET;
    CGFloat SHIP_STARTING_Y_OFFSET;

    CGFloat SHORT_DRAG_MIN;
    CGFloat DRAG_MIN;
    CGFloat LONG_DRAG_MIN;

    float widthScaleFactor;
    float heightScaleFactor;

    CGFloat gridStartingX;
    CGFloat gridStartingY;

    CGPoint gridCoordinates[7][9];

    NSMutableDictionary *settings;
    NSString *settingsFilePath;
    int savedLastGridPlayed;
    NSMutableArray *gkScores;
    NSMutableDictionary *gkAchievements;


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
@property (nonatomic, retain) IBOutlet EnergizeViewController *viewController;
@property (nonatomic, retain) IBOutlet UIViewController *currentViewController;
@property (nonatomic, retain) GLView *glView;
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (readonly, nonatomic) BOOL gameCenterAvailable;
@property (readonly, nonatomic) BOOL ios4orGreater;
@property (readonly, nonatomic) BOOL retinaDisplay;

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

@property (readonly, nonatomic) CGFloat FIREBALL_SPEED_HORIZONTAL;
@property (readonly, nonatomic) CGFloat FIREBALL_SPEED_VERTICAL;

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
@property (readonly, nonatomic) CGFloat SHIP_STARTING_X_OFFSET;
@property (readonly, nonatomic) CGFloat SHIP_STARTING_Y_OFFSET;

@property (readonly, nonatomic) float widthScaleFactor;
@property (readonly, nonatomic) float heightScaleFactor;

@property (readonly, nonatomic) CGFloat DRAG_MIN;
@property (readonly, nonatomic) CGFloat SHORT_DRAG_MIN;
@property (readonly, nonatomic) CGFloat LONG_DRAG_MIN;

@property (readonly, nonatomic) int savedLastGridPlayed;

- (void)startAnimation;
- (void)stopAnimation;
- (void)gameLoop;
- (void)renderCurrentScene;
- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (void)authenticationChanged;
- (CGPoint)getGridCoordinates:(int)row:(int)col;
- (void)calcGridCoordinates;
- (void)loadSettings;
- (void)saveSettings;
- (void)initSettingsFilePath;
- (void)resetLastGridPlayed;
- (void)reportScore:(int64_t)score forCategory:(NSString*)category;
- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent;
- (void)saveGKScores;
- (void)loadAndReportGKScores;
- (void)saveGKAchievements;
- (void)loadAndReportGKAchievements;

@end

