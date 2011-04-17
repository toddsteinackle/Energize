//
//  SettingsMenuViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CubeStormAppDelegate;
@class SoundManager;


@interface SettingsMenuViewController : UIViewController {
    CubeStormAppDelegate *appDelegate;
    SoundManager *sharedSoundManager;
    IBOutlet UISlider *musicVolume;
    IBOutlet UISlider *fxVolume;
    IBOutlet UISegmentedControl *thrustToggleOption;
    IBOutlet UISegmentedControl *dragDistance;
    IBOutlet UISwitch *initialShipThrust;
}

- (IBAction)musicValueChanged:(UISlider*)sender;
- (IBAction)fxValueChanged:(UISlider*)sender;
- (IBAction)thrustToggleOptionChanged:(UISegmentedControl*)sender;
- (IBAction)dragDistanceChanged:(UISegmentedControl*)sender;
- (IBAction)initialShipThrustChanged:(UISwitch*)sender;
- (IBAction)dismiss;
- (void)updateControlValues;

@end
