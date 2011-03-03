//
//  OpenGLViewController.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLView;
@class PauseMenuViewController;
@class CubeStormAppDelegate;

@interface OpenGLViewController : UIViewController {
    GLView *glView;
    PauseMenuViewController *pauseMenu;
    CubeStormAppDelegate *appDelegate;
}

- (void)showPauseView;
- (void)dismissPauseView;
- (void)quitGame;

@end
