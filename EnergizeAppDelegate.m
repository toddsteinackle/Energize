//
//  EnergizeAppDelegate.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "EnergizeAppDelegate.h"
#import "EnergizeViewController.h"
#import "GLESGameState.h"
#import "SoundManager.h"
#import "GLView.h"

BOOL isGameCenterAvailable() {
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

@implementation EnergizeAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize currentViewController;
@synthesize glView;
@synthesize animating;
@dynamic animationFrameInterval;
@synthesize gameCenterAvailable;
@synthesize ios4orGreater;
@synthesize retinaDisplay;
@synthesize SCREEN_HEIGHT;
@synthesize SCREEN_WIDTH;
@synthesize GUARDIAN_WIDTH;
@synthesize GUARDIAN_HEIGHT;
@synthesize GUARDIAN_RIGHT_BASE;
@synthesize GUARDIAN_LEFT_BASE;
@synthesize GUARDIAN_TOP_BASE;
@synthesize GUARDIAN_BOTTOM_BASE;
@synthesize GUARDIAN_LEFT_BOUND;
@synthesize GUARDIAN_RIGHT_BOUND;
@synthesize GUARDIAN_TOP_BOUND;
@synthesize GUARDIAN_BOTTOM_BOUND;
@synthesize GUARDIAN_SPEED_HORIZONTAL;
@synthesize GUARDIAN_SPEED_VERTICAL;
@synthesize SHIP_WIDTH;
@synthesize SHIP_HEIGHT;
@synthesize SHIP_SPEED_HORIZONTAL;
@synthesize SHIP_SPEED_VERTICAL;
@synthesize SHIP_TURBO_SPEED_HORIZONTAL;
@synthesize SHIP_TURBO_SPEED_VERTICAL;
@synthesize SHIP_LEFT_BOUND;
@synthesize SHIP_RIGHT_BOUND;
@synthesize SHIP_TOP_BOUND;
@synthesize SHIP_BOTTOM_BOUND;
@synthesize SHIP_STARTING_X_OFFSET;
@synthesize SHIP_STARTING_Y_OFFSET;
@synthesize widthScaleFactor;
@synthesize heightScaleFactor;
@synthesize DRAG_MIN;
@synthesize SHORT_DRAG_MIN;
@synthesize LONG_DRAG_MIN;
@synthesize FIREBALL_SPEED_HORIZONTAL;
@synthesize FIREBALL_SPEED_VERTICAL;
@synthesize savedLastGridPlayed;

#pragma mark -
#pragma mark Grid Coordinates

- (CGPoint)getGridCoordinates:(int)row:(int)col {
    return gridCoordinates[row][col];
}

- (void)calcGridCoordinates {
    gridStartingX = gridStartingX * widthScaleFactor;
    gridStartingY = gridStartingY * heightScaleFactor;
    CGFloat y;
    CGPoint coords;
    for (int i = 0; i < 7; ++i) {
        y = gridStartingY-(i*80*heightScaleFactor);
        for (int j = 0; j < 9; ++j) {
            coords = CGPointMake(gridStartingX+(j*80*widthScaleFactor), y);
            gridCoordinates[i][j] = coords;
        }
    }
}

#pragma mark -
#pragma mark Game Engine

#define MAXIMUM_FRAME_RATE 45
#define MINIMUM_FRAME_RATE 15
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

- (void)gameLoop {

    static double lastFrameTime = 0.0f;
    static double cyclesLeftOver = 0.0f;
    double currentTime;
    double updateIterations;

#ifdef FRAME_COUNTER
    double currTime = [[NSDate date] timeIntervalSince1970];
    m_FPS_framesThisSecond++;
    float timeThisSecond = currTime - m_FPS_lastSecondStart;
    if( timeThisSecond > 1.0f ) {
        m_FPS = m_FPS_framesThisSecond;
        m_FPS_framesThisSecond = 0;
        m_FPS_lastSecondStart = currTime;
        NSLog(@"fps -- %i", m_FPS);
    }
#endif

    // Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
    // network time and so could change causing hiccups.
    currentTime = CACurrentMediaTime();
    updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);

    if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
        updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);

    while (updateIterations >= UPDATE_INTERVAL) {
        updateIterations -= UPDATE_INTERVAL;

        // Update the game logic passing in the fixed update interval as the delta
        [((GLESGameState*)currentViewController.view) updateSceneWithDelta:UPDATE_INTERVAL];
    }

    cyclesLeftOver = updateIterations;
    lastFrameTime = currentTime;

    // Render the scene
    [((GLESGameState*)currentViewController.view) drawView:nil];
}

- (void) renderCurrentScene {
    [((GLESGameState*)currentViewController.view) renderScene];
}

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame interval is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(gameLoop)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval)
                                                              target:self selector:@selector(gameLoop) userInfo:nil repeats:TRUE];

        animating = TRUE;

        // Setup the lastTime ivar
        lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)stopAnimation {
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }

        animating = FALSE;
    }
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    GUARDIAN_WIDTH = 82;
    GUARDIAN_HEIGHT = 41;
    GUARDIAN_SPEED_HORIZONTAL = 130;
    GUARDIAN_SPEED_VERTICAL = 130;
    GUARDIAN_RIGHT_BASE = 945;
    GUARDIAN_LEFT_BASE = 15;
    GUARDIAN_TOP_BASE = 730;
    GUARDIAN_BOTTOM_BASE = 15;

    SHIP_WIDTH = 41;
    SHIP_HEIGHT = 41;
    SHIP_SPEED_HORIZONTAL = 145;
    SHIP_SPEED_VERTICAL = 145;
    SHIP_TURBO_SPEED_HORIZONTAL = 225;
    SHIP_TURBO_SPEED_VERTICAL = 225;
    SHIP_STARTING_X_OFFSET = 20;
    SHIP_STARTING_Y_OFFSET = 20;

    FIREBALL_SPEED_HORIZONTAL = 75;
    FIREBALL_SPEED_VERTICAL = 75;

    CGFloat guardian_width_padding, guardian_height_padding;
    guardian_width_padding = guardian_height_padding = 5;
    GUARDIAN_LEFT_BOUND = GUARDIAN_LEFT_BASE + GUARDIAN_HEIGHT + guardian_width_padding;
    GUARDIAN_RIGHT_BOUND = GUARDIAN_RIGHT_BASE - GUARDIAN_HEIGHT - guardian_width_padding;
    GUARDIAN_TOP_BOUND = GUARDIAN_TOP_BASE - GUARDIAN_HEIGHT - guardian_width_padding;
    GUARDIAN_BOTTOM_BOUND = GUARDIAN_BOTTOM_BASE + GUARDIAN_HEIGHT + guardian_width_padding;

    CGFloat ship_width_padding, ship_height_padding;
    ship_width_padding = ship_height_padding = 10;
    SHIP_LEFT_BOUND = GUARDIAN_LEFT_BASE + GUARDIAN_HEIGHT + ship_width_padding;
    SHIP_RIGHT_BOUND = GUARDIAN_RIGHT_BASE - GUARDIAN_HEIGHT - ship_width_padding;
    SHIP_TOP_BOUND = GUARDIAN_TOP_BASE - GUARDIAN_HEIGHT - ship_width_padding;
    SHIP_BOTTOM_BOUND = GUARDIAN_BOTTOM_BASE + GUARDIAN_HEIGHT + ship_width_padding;

    gridStartingX = 160;
    gridStartingY = 612;

    SHORT_DRAG_MIN = 5;
    DRAG_MIN = 10;
    LONG_DRAG_MIN = 15;

    // check for retina display
    // You can't detect screen resolutions in pre 3.2 devices, but they are all 320x480
    NSString *reqSysVer = @"3.2";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    if (osVersionSupported) {
        UIScreen* mainscr = [UIScreen mainScreen];
        int w = mainscr.currentMode.size.width;
        int h = mainscr.currentMode.size.height;
        if (w == 640 && h == 960) {
            retinaDisplay = TRUE;
        } else {
            retinaDisplay = FALSE;
        }
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        SCREEN_WIDTH = 1024;
        SCREEN_HEIGHT = 768;
        widthScaleFactor = 1.0;
        heightScaleFactor = 1.0;
        [self calcGridCoordinates];

    } else {

        if (retinaDisplay) {
            SCREEN_WIDTH = 960;
            SCREEN_HEIGHT = 640;
            widthScaleFactor = 0.9375;
            heightScaleFactor = 0.83333333333333333333;
        } else {
            SCREEN_WIDTH = 480;
            SCREEN_HEIGHT = 320;
            widthScaleFactor = 0.46875;
            heightScaleFactor = 0.416666667;
        }
        [self calcGridCoordinates];

        GUARDIAN_WIDTH = GUARDIAN_WIDTH * widthScaleFactor;
        GUARDIAN_HEIGHT = GUARDIAN_HEIGHT * heightScaleFactor;
        GUARDIAN_SPEED_HORIZONTAL = GUARDIAN_SPEED_HORIZONTAL * widthScaleFactor;
        GUARDIAN_SPEED_VERTICAL = GUARDIAN_SPEED_VERTICAL * heightScaleFactor;
        GUARDIAN_RIGHT_BASE = GUARDIAN_RIGHT_BASE * widthScaleFactor;
        GUARDIAN_LEFT_BASE = GUARDIAN_LEFT_BASE * widthScaleFactor;
        GUARDIAN_TOP_BASE = GUARDIAN_TOP_BASE * heightScaleFactor;
        GUARDIAN_BOTTOM_BASE = GUARDIAN_BOTTOM_BASE * heightScaleFactor;
        guardian_width_padding = guardian_width_padding * widthScaleFactor;
        guardian_height_padding = guardian_height_padding * heightScaleFactor;
        GUARDIAN_LEFT_BOUND = GUARDIAN_LEFT_BASE + GUARDIAN_HEIGHT + guardian_width_padding;
        GUARDIAN_RIGHT_BOUND = GUARDIAN_RIGHT_BASE - GUARDIAN_HEIGHT - guardian_width_padding;
        GUARDIAN_TOP_BOUND = GUARDIAN_TOP_BASE - GUARDIAN_HEIGHT - guardian_height_padding;
        GUARDIAN_BOTTOM_BOUND = GUARDIAN_BOTTOM_BASE + GUARDIAN_HEIGHT + guardian_height_padding;

        SHIP_WIDTH = SHIP_WIDTH * widthScaleFactor;
        SHIP_HEIGHT = SHIP_HEIGHT * heightScaleFactor;
        SHIP_SPEED_HORIZONTAL = SHIP_SPEED_HORIZONTAL * widthScaleFactor;
        SHIP_SPEED_VERTICAL = SHIP_SPEED_VERTICAL * heightScaleFactor;
        SHIP_TURBO_SPEED_HORIZONTAL = SHIP_TURBO_SPEED_HORIZONTAL * widthScaleFactor;
        SHIP_TURBO_SPEED_VERTICAL = SHIP_TURBO_SPEED_VERTICAL * heightScaleFactor;
        ship_width_padding = ship_width_padding * widthScaleFactor;
        ship_height_padding = ship_height_padding * heightScaleFactor;
        SHIP_LEFT_BOUND = GUARDIAN_LEFT_BASE + GUARDIAN_HEIGHT + ship_width_padding;
        SHIP_RIGHT_BOUND = GUARDIAN_RIGHT_BASE - GUARDIAN_HEIGHT - ship_width_padding;
        SHIP_TOP_BOUND = GUARDIAN_TOP_BASE - GUARDIAN_HEIGHT - ship_height_padding;
        SHIP_BOTTOM_BOUND = GUARDIAN_BOTTOM_BASE + GUARDIAN_HEIGHT + ship_height_padding;
        SHIP_STARTING_X_OFFSET = SHIP_STARTING_X_OFFSET * widthScaleFactor;
        SHIP_STARTING_Y_OFFSET = SHIP_STARTING_Y_OFFSET * heightScaleFactor;
//        DRAG_MIN_X = DRAG_MIN_X * widthScaleFactor;
//        DRAG_MIN_Y = DRAG_MIN_Y * heightScaleFactor;
        FIREBALL_SPEED_HORIZONTAL = FIREBALL_SPEED_HORIZONTAL * widthScaleFactor;
        FIREBALL_SPEED_VERTICAL = FIREBALL_SPEED_VERTICAL * heightScaleFactor;
    }

    if (isGameCenterAvailable()) {
        gameCenterAvailable = TRUE;
    }

    sharedSoundManager = [SoundManager sharedSoundManager];
    [viewController customInit];
    [self loadSettings];

    //now set our view as visible
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;

    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    reqSysVer = @"3.1";
    currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
    reqSysVer = @"4.0";
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        ios4orGreater = TRUE;
    reqSysVer = @"4.2.1";
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedDescending)
        animationFrameInterval = 2;

    currentViewController = viewController;

#ifdef GAMECENTER
    if (gameCenterAvailable) {
#ifdef GAMECENTER_DEBUG
        NSLog(@"Game Center Available");
#endif
        [self authenticateLocalPlayer];
        [self registerForAuthenticationNotification];
    } else {
#ifdef GAMECENTER_DEBUG
        NSLog(@"Game Center Not Available");
#endif
        gameCenterAvailable = FALSE;
    }
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an
     incoming phone call or SMS message) or when the user quits the application
     and it begins the transition to the background state.

     Use this method to pause ongoing tasks, disable timers, and throttle down
     OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self stopAnimation];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate
     timers, and store enough application state information to restore your
     application to its current state in case it is terminated later.

     If your application supports background execution, called instead of
     applicationWillTerminate: when the user quits.
     */
    [self saveSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state:
     here you can undo many of the changes made on entering the background.
     */
    [self loadSettings];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the
     application was inactive. If the application was previously in the
     background, optionally refresh the user interface.
     */
    if ([currentViewController.view isKindOfClass:[GLESGameState class]]) {
        [self startAnimation];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [self stopAnimation];
    [self saveSettings];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark -
#pragma mark Game Center

- (void)authenticateLocalPlayer {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error == nil)
        {
            // Insert code here to handle a successful authentication.
#ifdef GAMECENTER_DEBUG
            NSLog(@"player authenticated -- initial");
#endif
        }

        else
        {
            // Your application can process the error parameter to report the error to the player.
#ifdef GAMECENTER_DEBUG
            NSLog(@"GC authenticateWithCompletionHandler error");
#endif
        }
    }];
}

- (void)registerForAuthenticationNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        // Insert code here to handle a successful authentication.
#ifdef GAMECENTER_DEBUG
        NSLog(@"player authenticated -- authenticationChanged");
#endif
        //[self loadAndReportGKScores];
    } else {
#ifdef GAMECENTER_DEBUG
        NSLog(@"authenticationChanged player not authenticated");
#endif
        // Insert code here to clean up any outstanding Game Center-related classes.
    }

}

#pragma mark -
#pragma mark Settings

- (void)loadSettings {
#ifdef GAMEENGINE_DEBUG
    NSLog(@"INFO - App Delegate: Loading settings.");
#endif
    // If the prefs file has not been initialised then init the prefs file
    if(settingsFilePath == nil)
        [self initSettingsFilePath];

    // If the prefs file cannot be found then create it with default values
    if([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]) {
#ifdef GAMEENGINE_DEBUG
        NSLog(@"INFO - App Delegate: Found settings file");
#endif
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFilePath];
    } else {
#ifdef GAMEENGINE_DEBUG
        NSLog(@"INFO - App Delegate: No settings file, creating defaults");
#endif
        settings = [[NSMutableDictionary alloc] init];
        [settings setObject:[NSString stringWithFormat:@"%f", 0.5f] forKey:@"musicVolume"];
        [settings setObject:[NSString stringWithFormat:@"%f", 0.75f] forKey:@"fxVolume"];
        [settings setObject:[NSNumber numberWithBool:TRUE] forKey:@"defaultShipThrust"];
        [settings setObject:[NSNumber numberWithInt:1] forKey:@"tapsToToggle"];
        [settings setObject:[NSNumber numberWithDouble:self.DRAG_MIN] forKey:@"minDragDistance"];
        [settings setObject:[NSNumber numberWithInt:1] forKey:@"skillLevel"];
        [settings setObject:[NSNumber numberWithBool:FALSE] forKey:@"randomGridPlayOption"];
        [settings setObject:[NSNumber numberWithInt:1] forKey:@"lastGridPlayed"];
    }

    // Get the prefs from the pref file
    [sharedSoundManager setMusicVolume:[(NSString *)[settings valueForKey:@"musicVolume"] floatValue]];
    [sharedSoundManager setFxVolume:[(NSString *)[settings valueForKey:@"fxVolume"] floatValue]];
    self.glView.shipThrustingDefault = [[settings valueForKey:@"defaultShipThrust"] boolValue];
    self.glView.tapsNeededToToggleThrust = [[settings valueForKey:@"tapsToToggle"] intValue] + 1;
    self.glView.drag_min = [[settings valueForKey:@"minDragDistance"] doubleValue];
    self.glView.skillLevel = [[settings valueForKey:@"skillLevel"] intValue];
    self.glView.randomGridPlayOption = [[settings valueForKey:@"randomGridPlayOption"] boolValue];
    savedLastGridPlayed = [[settings valueForKey:@"lastGridPlayed"] intValue];
}

- (void)saveSettings {
    // Save the current settings to the apps prefs file
    NSNumber *mv = [NSNumber numberWithFloat:sharedSoundManager.musicVolume];
    NSNumber *fv = [NSNumber numberWithFloat:sharedSoundManager.fxVolume];
    NSNumber *shipThrust = [NSNumber numberWithBool:self.glView.shipThrustingDefault];
    NSNumber *tapsToToggle = [NSNumber numberWithInt:self.glView.tapsNeededToToggleThrust-1];
    NSNumber *minDragDistance = [NSNumber numberWithDouble:self.glView.drag_min];
    NSNumber *skillLevel = [NSNumber numberWithInt:self.glView.skillLevel];
    NSNumber *randomGridPlayOption = [NSNumber numberWithBool:self.glView.randomGridPlayOption];
    NSNumber *lastGridPlayed = [NSNumber numberWithInt:self.glView.lastGridPlayed];
    [settings setObject:mv forKey:@"musicVolume"];
    [settings setObject:fv forKey:@"fxVolume"];
    [settings setObject:shipThrust forKey:@"defaultShipThrust"];
    [settings setObject:tapsToToggle forKey:@"tapsToToggle"];
    [settings setObject:minDragDistance forKey:@"minDragDistance"];
    [settings setObject:skillLevel forKey:@"skillLevel"];
    [settings setObject:randomGridPlayOption forKey:@"randomGridPlayOption"];
    if ([[settings valueForKey:@"lastGridPlayed"] intValue] < self.glView.lastGridPlayed) {
        [settings setObject:lastGridPlayed forKey:@"lastGridPlayed"];
    }
    [settings writeToFile:settingsFilePath atomically:YES];
#ifdef GAMEENGINE_DEBUG
    NSLog(@"INFO - App Delegate: Saving musicVolume=%f, fxVolume=%f, defaultShipThrust=%i, tapsToToggle=%i",
          [mv floatValue], [fv floatValue], [shipThrust boolValue], [tapsToToggle intValue]);
    NSLog(@"minDragDistance=%f, skillLevel=%i, randomGridPlayOption=%i, lastGridPlayed=%i",
          [minDragDistance doubleValue], [skillLevel intValue], [randomGridPlayOption boolValue], savedLastGridPlayed);
#endif
}

- (void)resetLastGridPlayed {
    [settings setObject:[NSNumber numberWithInt:1] forKey:@"lastGridPlayed"];
}

- (void)initSettingsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    settingsFilePath = [documentsDirectory stringByAppendingPathComponent:@"energize.plist"];
    [settingsFilePath retain];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can
     be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
