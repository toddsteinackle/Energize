//
//  SettingsMenuViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CubeStormAppDelegate;


@interface SettingsMenuViewController : UIViewController {
    CubeStormAppDelegate *appDelegate;
}

- (IBAction)dismiss;

@end
