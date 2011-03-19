//
//  CubeStormViewController.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "CubeStormViewController.h"
#import "CubeStormAppDelegate.h"
#import "SettingsMenuViewController.h"
#import "OpenGLViewController.h"
#import "MainMenuView.h"
#import "Constants.h"

@implementation CubeStormViewController

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

- (void)showSettingsMenu {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:settingsMenu animated:YES];
    appDelegate.currentViewController = settingsMenu;
}

- (void)showGLView {
    appDelegate.currentViewController = glViewController;
    [appDelegate startAnimation];
    [self presentModalViewController:glViewController animated:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        mainMenu = [[MainMenuView alloc] initWithFrame:CGRectMake(0, 0, IPAD_WIDTH, IPAD_HEIGHT)];
    } else {
        mainMenu = [[MainMenuView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    }
    self.view = mainMenu;
    glViewController = [[OpenGLViewController alloc] initWithNibName:nil bundle:nil];
    appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = mainMenu;
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
    [super dealloc];
}

@end
