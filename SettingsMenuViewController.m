//
//  SettingsMenuViewController.m
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "SettingsMenuViewController.h"
#import "CubeStormAppDelegate.h"
#import "SoundManager.h"
#import "GLView.h"


@implementation SettingsMenuViewController

- (IBAction)dismiss {
    [appDelegate saveSettings];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self release];
    appDelegate.currentViewController = self.parentViewController;
}

- (IBAction)musicValueChanged:(UISlider*)sender {
    sharedSoundManager.musicVolume = [sender value];
}

- (IBAction)fxValueChanged:(UISlider*)sender {
    sharedSoundManager.fxVolume = [sender value];
}

- (IBAction)thrustToggleOptionChanged:(UISegmentedControl*)sender {
    appDelegate.glView.tapsNeededToToggleThrust = sender.selectedSegmentIndex + 1;
}

- (IBAction)dragDistanceChanged:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            appDelegate.glView.drag_min = appDelegate.SHORT_DRAG_MIN;
            break;
        case 1:
            appDelegate.glView.drag_min = appDelegate.DRAG_MIN;
            break;
        case 2:
            appDelegate.glView.drag_min = appDelegate.LONG_DRAG_MIN;
            break;

        default:
            break;
    }
}

- (IBAction)initialShipThrustChanged:(UISwitch*)sender {
    appDelegate.glView.shipThrustingDefault = sender.on;
}

- (void)updateControlValues {
    musicVolume.value = sharedSoundManager.musicVolume;
    fxVolume.value = sharedSoundManager.fxVolume;
    initialShipThrust.on = appDelegate.glView.shipThrustingDefault;
    thrustToggleOption.selectedSegmentIndex = appDelegate.glView.tapsNeededToToggleThrust - 1;
    if (appDelegate.glView.drag_min == appDelegate.SHORT_DRAG_MIN) {
        dragDistance.selectedSegmentIndex = 0;
    } else  if (appDelegate.glView.drag_min == appDelegate.DRAG_MIN) {
        dragDistance.selectedSegmentIndex = 1;
    } else if (appDelegate.glView.drag_min == appDelegate.LONG_DRAG_MIN) {
        dragDistance.selectedSegmentIndex = 2;
    }
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
