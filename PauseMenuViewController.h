//
//  PauseMenuViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLViewController;
@class SettingsMenuViewController;

@interface PauseMenuViewController : UIViewController {
    OpenGLViewController *callingController;
    SettingsMenuViewController *settingsMenu;
}

@property (nonatomic, retain) OpenGLViewController *callingController;

- (IBAction)dismiss;
- (IBAction)quit;
- (IBAction)showSettingsMenu;

@end
