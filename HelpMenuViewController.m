//
//  HelpMenuViewController.m
//  Energize
//
//  Created by Todd Steinackle on 4/22/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "HelpMenuViewController.h"
#import "EnergizeAppDelegate.h"
#import "SoundManager.h"


@implementation HelpMenuViewController

- (IBAction)dismiss {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    [self release];
    appDelegate.currentViewController = self.parentViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        appDelegate = (EnergizeAppDelegate *)[[UIApplication sharedApplication] delegate];
        sharedSoundManager = [SoundManager sharedSoundManager];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
