//
//  OpenGLViewController.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "OpenGLViewController.h"
#import "PauseMenuViewController.h"
#import "CubeStormViewController.h"
#import "CubeStormAppDelegate.h"
#import "GLView.h"
#import "Globals.h"


@implementation OpenGLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            glView = [[GLView alloc] initWithFrame:CGRectMake(0, 0, IPAD_WIDTH, IPAD_HEIGHT)];
        } else {
            glView = [[GLView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
        }
        self.view = glView;
        glView.viewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            pauseMenu = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenuViewController-iPad" bundle:[NSBundle mainBundle]];
        } else {
            pauseMenu = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenuViewController" bundle:[NSBundle mainBundle]];
        }
        pauseMenu.callingController = self;
        appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)showPauseView {
    [appDelegate stopAnimation];
    [self presentModalViewController:pauseMenu animated:YES];
    appDelegate.currentViewController = pauseMenu;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dismissPauseView {
    [self dismissModalViewControllerAnimated:YES];
    appDelegate.currentViewController = self;
    [appDelegate startAnimation];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)quitGame {
    if (appDelegate.ios4orGreater) {
        [appDelegate.viewController dismissGLView];
    } else {
        [self dismissModalViewControllerAnimated:NO];
        [appDelegate stopAnimation];
        [self dismissModalViewControllerAnimated:NO];
        appDelegate.currentViewController = appDelegate.viewController;
    }
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [glView release];
    [pauseMenu release];
    [super dealloc];
}


@end
