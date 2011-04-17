//
//  PlayOptionsMenuViewController.m
//  CubeStorm
//
//  Created by Todd Steinackle on 4/17/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "PlayOptionsMenuViewController.h"
#import "CubeStormAppDelegate.h"
#import "SoundManager.h"
#import "GLView.h"


@implementation PlayOptionsMenuViewController

- (IBAction)dismiss {
    [appDelegate saveSettings];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self release];
    appDelegate.currentViewController = self.parentViewController;
}

- (IBAction)skillLevelOptionChanged:(UISegmentedControl*)sender {
    appDelegate.glView.skillLevel = sender.selectedSegmentIndex;
}

- (IBAction)randomGridOptionChanged:(UISegmentedControl*)sender {
    appDelegate.glView.randomGridPlayOption = sender.selectedSegmentIndex;
}

- (void)updateControlValues {
    skillLevelOption.selectedSegmentIndex = appDelegate.glView.skillLevel;
    randomGridOption.selectedSegmentIndex = appDelegate.glView.randomGridPlayOption;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];
        sharedSoundManager = [SoundManager sharedSoundManager];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateControlValues];
}



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
