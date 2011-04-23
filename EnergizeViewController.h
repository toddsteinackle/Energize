//
//  EnergizeViewController.h
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class SettingsMenuViewController;
@class EnergizeAppDelegate;
@class OpenGLViewController;
@class MainMenuView;
@class PlayOptionsMenuViewController;
@class AboutMenuViewController;
@class HelpMenuViewController;

@interface EnergizeViewController : UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
    GKLeaderboardViewController *leaderboardController;
    SettingsMenuViewController *settingsMenu;
    PlayOptionsMenuViewController *playOptionsMenu;
    EnergizeAppDelegate *appDelegate;
    OpenGLViewController *glViewController;
    MainMenuView *mainMenu;
    AboutMenuViewController *aboutMenu;
    HelpMenuViewController *helpMenu;
}

- (void)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void)showAchievements;
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
- (void)showSettingsMenu;
- (void)showGLView;
- (void)dismissGLView;
- (void)customInit;
- (void)showPlayOptionsMenu;
- (void)showAbout;
- (void)showHelp;

@end

