//
//  CubeStormViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class SettingsMenuViewController;
@class CubeStormAppDelegate;
@class OpenGLViewController;
@class MainMenuView;

@interface CubeStormViewController : UIViewController <GKLeaderboardViewControllerDelegate> {
    GKLeaderboardViewController *leaderboardController;
    SettingsMenuViewController *settingsMenu;
    CubeStormAppDelegate *appDelegate;
    OpenGLViewController *glViewController;
    MainMenuView *mainMenu;
}

- (void)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void)showSettingsMenu;
- (void)showGLView;
- (void)dismissGLView;
- (void)customInit;

@end

