//
//  EnergizeViewController.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "EnergizeViewController.h"
#import "EnergizeAppDelegate.h"
#import "SettingsMenuViewController.h"
#import "PlayOptionsMenuViewController.h"
#import "OpenGLViewController.h"
#import "MainMenuView.h"
#import "GLView.h"
#import "AboutMenuViewController.h"
#import "HelpMenuViewController.h"
#import "SoundManager.h"

@implementation EnergizeViewController

- (void)showLeaderboard {
    leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [self presentModalViewController:leaderboardController animated:YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
    [leaderboardController release];
}

- (void)showAchievements {
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil) {
        achievements.achievementDelegate = self;
        [self presentModalViewController:achievements animated:YES];
    }
    [achievements release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showSettingsMenu {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:settingsMenu animated:YES];
    appDelegate.currentViewController = settingsMenu;
}

- (void)showPlayOptionsMenu {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        playOptionsMenu = [[PlayOptionsMenuViewController alloc] initWithNibName:@"PlayOptionsMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        playOptionsMenu = [[PlayOptionsMenuViewController alloc] initWithNibName:@"PlayOptionsMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:playOptionsMenu animated:YES];
    appDelegate.currentViewController = playOptionsMenu;
}

- (void)showAbout {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        aboutMenu = [[AboutMenuViewController alloc] initWithNibName:@"AboutMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        aboutMenu = [[AboutMenuViewController alloc] initWithNibName:@"AboutMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:aboutMenu animated:YES];
    appDelegate.currentViewController = aboutMenu;
}

- (void)showHelp {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        helpMenu = [[HelpMenuViewController alloc] initWithNibName:@"HelpMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        helpMenu = [[HelpMenuViewController alloc] initWithNibName:@"HelpMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:helpMenu animated:YES];
    appDelegate.currentViewController = helpMenu;
}

- (void)showGLView {
    appDelegate.currentViewController = glViewController;
    [appDelegate startAnimation];
    [self presentModalViewController:glViewController animated:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [sharedSoundManager stopMusic];
}

- (void)dismissGLView {
    [appDelegate stopAnimation];
    [self dismissModalViewControllerAnimated:YES];
    appDelegate.currentViewController = self;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}

- (void)customInit {
    appDelegate = (EnergizeAppDelegate *)[[UIApplication sharedApplication] delegate];
    sharedSoundManager = [SoundManager sharedSoundManager];
    glViewController = [[OpenGLViewController alloc] initWithNibName:nil bundle:nil];
    mainMenu = [[MainMenuView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.SCREEN_WIDTH, appDelegate.SCREEN_HEIGHT)];
    self.view = mainMenu;
    [sharedSoundManager loadMusicWithKey:@"menu_music" musicFile:@"01IntroTitle.m4a"];
    [sharedSoundManager playMusicWithKey:@"menu_music" timesToRepeat:-1];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = mainMenu;


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate loadSettings];
    if (appDelegate.glView.randomGridPlayOption) {
        mainMenu.startAtGridButton.enabled = FALSE;
        [mainMenu.startAtGridButton setTitle:[NSString stringWithFormat:@"Start at Grid:"]
                                    forState:UIControlStateNormal];
    } else {
        mainMenu.startAtGridButton.enabled = TRUE;
        [mainMenu.startAtGridButton setTitle:[NSString stringWithFormat:@"Start at Grid: %i", appDelegate.savedLastGridPlayed]
                                    forState:UIControlStateNormal];
    }
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [glViewController release];
    [mainMenu release];
    [sharedSoundManager removeMusicWithKey:@"menu_music"];
    [super dealloc];
}

@end
