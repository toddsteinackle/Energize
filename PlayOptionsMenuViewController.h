//
//  PlayOptionsMenuViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 4/17/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CubeStormAppDelegate;
@class SoundManager;


@interface PlayOptionsMenuViewController : UIViewController {
    CubeStormAppDelegate *appDelegate;
    SoundManager *sharedSoundManager;
    IBOutlet UISegmentedControl *skillLevelOption;
    IBOutlet UISegmentedControl *randomGridOption;
}

- (IBAction)dismiss;
- (void)updateControlValues;
- (IBAction)skillLevelOptionChanged:(UISegmentedControl*)sender;
- (IBAction)randomGridOptionChanged:(UISegmentedControl*)sender;

@end
