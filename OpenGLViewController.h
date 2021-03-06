//
//  OpenGLViewController.h
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLView;
@class PauseMenuViewController;
@class EnergizeAppDelegate;
@class SoundManager;

@interface OpenGLViewController : UIViewController {
    GLView *glView;
    PauseMenuViewController *pauseMenu;
    EnergizeAppDelegate *appDelegate;
    SoundManager *sharedSoundManager;
}

- (void)showPauseView;
- (void)dismissPauseView;
- (void)quitGame;

@end
