//
//  PauseMenuViewController.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "PauseMenuViewController.h"
#import "OpenGLViewController.h"
#import "SettingsMenuViewController.h"


@implementation PauseMenuViewController

@synthesize callingController;

- (IBAction)dismiss {
    [callingController dismissPauseView];
}

- (IBAction)quit {
    [callingController quitGame];
}

- (IBAction)showSettingsMenu {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController-iPad" bundle:[NSBundle mainBundle]];
    } else {
        settingsMenu = [[SettingsMenuViewController alloc] initWithNibName:@"SettingsMenuViewController" bundle:[NSBundle mainBundle]];
    }
    [self presentModalViewController:settingsMenu animated:YES];
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
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
    [super dealloc];
}


@end
