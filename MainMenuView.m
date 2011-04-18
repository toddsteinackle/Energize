//
//  MainMenuView.m

#import "MainMenuView.h"
#import "EnergizeAppDelegate.h"
#import "EnergizeViewController.h"
#import "GLView.h"

@implementation MainMenuView

@synthesize startAtGridButton;

- (MainMenuView*)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        //load the .xib file here.
        //this will instantiate the 'subview' uiview.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[NSBundle mainBundle] loadNibNamed:@"MainMenuView-iPad" owner:self options:nil];
        } else {
            [[NSBundle mainBundle] loadNibNamed:@"MainMenuView" owner:self options:nil];
        }

        //add subview as... a subview.
        //this will let everything from the nib file show up on screen.
        [self addSubview:subview];
        appDelegate = (EnergizeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!appDelegate.gameCenterAvailable) {
            leaderboardButton.hidden = TRUE;
            achievementButton.hidden = TRUE;
            CGFloat vDistance = 45;
            newGameButton.center = CGPointMake(newGameButton.center.x, newGameButton.center.y + vDistance * appDelegate.heightScaleFactor);
            startAtGridButton.center = CGPointMake(startAtGridButton.center.x, startAtGridButton.center.y + vDistance * appDelegate.heightScaleFactor);
            playSettingsButton.center = CGPointMake(playSettingsButton.center.x, playSettingsButton.center.y + vDistance * appDelegate.heightScaleFactor);
            controlSettingsButton.center = CGPointMake(controlSettingsButton.center.x, controlSettingsButton.center.y + vDistance * appDelegate.heightScaleFactor);
            helpButton.center = CGPointMake(helpButton.center.x, helpButton.center.y + vDistance * appDelegate.heightScaleFactor);
            aboutButton.center = CGPointMake(aboutButton.center.x, aboutButton.center.y + vDistance * appDelegate.heightScaleFactor);
        }

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // set up our UIImage with a group or array of images to animate
            purpleCube.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"iPadPurple0008.png"],
                                            [UIImage imageNamed:@"iPadPurple0009.png"],
                                            [UIImage imageNamed:@"iPadPurple0010.png"],
                                            [UIImage imageNamed:@"iPadPurple0011.png"],
                                            [UIImage imageNamed:@"iPadPurple0012.png"],
                                            [UIImage imageNamed:@"iPadPurple0013.png"],
                                            [UIImage imageNamed:@"iPadPurple0014.png"],
                                            [UIImage imageNamed:@"iPadPurple0015.png"],
                                            [UIImage imageNamed:@"iPadPurple0016.png"],
                                            [UIImage imageNamed:@"iPadPurple0005.png"],
                                            [UIImage imageNamed:@"iPadPurple0006.png"],
                                            [UIImage imageNamed:@"iPadPurple0007.png"],
                                            nil];
            purpleCube.animationDuration = .6;
            [purpleCube startAnimating];

            redCube.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"iPadRed0016.png"],
                                            [UIImage imageNamed:@"iPadRed0015.png"],
                                            [UIImage imageNamed:@"iPadRed0014.png"],
                                            [UIImage imageNamed:@"iPadRed0013.png"],
                                            [UIImage imageNamed:@"iPadRed0012.png"],
                                            [UIImage imageNamed:@"iPadRed0011.png"],
                                            [UIImage imageNamed:@"iPadRed0010.png"],
                                            [UIImage imageNamed:@"iPadRed0009.png"],
                                            [UIImage imageNamed:@"iPadRed0008.png"],
                                            [UIImage imageNamed:@"iPadRed0007.png"],
                                            [UIImage imageNamed:@"iPadRed0006.png"],
                                            [UIImage imageNamed:@"iPadRed0005.png"],
                                            nil];
            redCube.animationDuration = .6;
            [redCube startAnimating];

            purpleCube2.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"iPadPurple0008.png"],
                                            [UIImage imageNamed:@"iPadPurple0009.png"],
                                            [UIImage imageNamed:@"iPadPurple0010.png"],
                                            [UIImage imageNamed:@"iPadPurple0011.png"],
                                            [UIImage imageNamed:@"iPadPurple0012.png"],
                                            [UIImage imageNamed:@"iPadPurple0013.png"],
                                            [UIImage imageNamed:@"iPadPurple0014.png"],
                                            [UIImage imageNamed:@"iPadPurple0015.png"],
                                            [UIImage imageNamed:@"iPadPurple0016.png"],
                                            [UIImage imageNamed:@"iPadPurple0005.png"],
                                            [UIImage imageNamed:@"iPadPurple0006.png"],
                                            [UIImage imageNamed:@"iPadPurple0007.png"],
                                            nil];
            purpleCube2.animationDuration = .6;
            [purpleCube2 startAnimating];

            redCube2.animationImages = [NSArray arrayWithObjects:
                                            [UIImage imageNamed:@"iPadRed0016.png"],
                                            [UIImage imageNamed:@"iPadRed0015.png"],
                                            [UIImage imageNamed:@"iPadRed0014.png"],
                                            [UIImage imageNamed:@"iPadRed0013.png"],
                                            [UIImage imageNamed:@"iPadRed0012.png"],
                                            [UIImage imageNamed:@"iPadRed0011.png"],
                                            [UIImage imageNamed:@"iPadRed0010.png"],
                                            [UIImage imageNamed:@"iPadRed0009.png"],
                                            [UIImage imageNamed:@"iPadRed0008.png"],
                                            [UIImage imageNamed:@"iPadRed0007.png"],
                                            [UIImage imageNamed:@"iPadRed0006.png"],
                                            [UIImage imageNamed:@"iPadRed0005.png"],
                                            nil];
            redCube2.animationDuration = .6;
            [redCube2 startAnimating];
        } else {
            // iphone cubes
            purpleCube.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"iPhonePurple0008.png"],
                                          [UIImage imageNamed:@"iPhonePurple0009.png"],
                                          [UIImage imageNamed:@"iPhonePurple0010.png"],
                                          [UIImage imageNamed:@"iPhonePurple0011.png"],
                                          [UIImage imageNamed:@"iPhonePurple0012.png"],
                                          [UIImage imageNamed:@"iPhonePurple0013.png"],
                                          [UIImage imageNamed:@"iPhonePurple0014.png"],
                                          [UIImage imageNamed:@"iPhonePurple0015.png"],
                                          [UIImage imageNamed:@"iPhonePurple0016.png"],
                                          [UIImage imageNamed:@"iPhonePurple0005.png"],
                                          [UIImage imageNamed:@"iPhonePurple0006.png"],
                                          [UIImage imageNamed:@"iPhonePurple0007.png"],
                                          nil];
            purpleCube.animationDuration = .6;
            [purpleCube startAnimating];

            redCube.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"iPhoneRed0016.png"],
                                       [UIImage imageNamed:@"iPhoneRed0015.png"],
                                       [UIImage imageNamed:@"iPhoneRed0014.png"],
                                       [UIImage imageNamed:@"iPhoneRed0013.png"],
                                       [UIImage imageNamed:@"iPhoneRed0012.png"],
                                       [UIImage imageNamed:@"iPhoneRed0011.png"],
                                       [UIImage imageNamed:@"iPhoneRed0010.png"],
                                       [UIImage imageNamed:@"iPhoneRed0009.png"],
                                       [UIImage imageNamed:@"iPhoneRed0008.png"],
                                       [UIImage imageNamed:@"iPhoneRed0007.png"],
                                       [UIImage imageNamed:@"iPhoneRed0006.png"],
                                       [UIImage imageNamed:@"iPhoneRed0005.png"],
                                       nil];
            redCube.animationDuration = .6;
            [redCube startAnimating];

            purpleCube2.animationImages = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"iPhonePurple0008.png"],
                                           [UIImage imageNamed:@"iPhonePurple0009.png"],
                                           [UIImage imageNamed:@"iPhonePurple0010.png"],
                                           [UIImage imageNamed:@"iPhonePurple0011.png"],
                                           [UIImage imageNamed:@"iPhonePurple0012.png"],
                                           [UIImage imageNamed:@"iPhonePurple0013.png"],
                                           [UIImage imageNamed:@"iPhonePurple0014.png"],
                                           [UIImage imageNamed:@"iPhonePurple0015.png"],
                                           [UIImage imageNamed:@"iPhonePurple0016.png"],
                                           [UIImage imageNamed:@"iPhonePurple0005.png"],
                                           [UIImage imageNamed:@"iPhonePurple0006.png"],
                                           [UIImage imageNamed:@"iPhonePurple0007.png"],
                                           nil];
            purpleCube2.animationDuration = .6;
            [purpleCube2 startAnimating];

            redCube2.animationImages = [NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"iPhoneRed0016.png"],
                                        [UIImage imageNamed:@"iPhoneRed0015.png"],
                                        [UIImage imageNamed:@"iPhoneRed0014.png"],
                                        [UIImage imageNamed:@"iPhoneRed0013.png"],
                                        [UIImage imageNamed:@"iPhoneRed0012.png"],
                                        [UIImage imageNamed:@"iPhoneRed0011.png"],
                                        [UIImage imageNamed:@"iPhoneRed0010.png"],
                                        [UIImage imageNamed:@"iPhoneRed0009.png"],
                                        [UIImage imageNamed:@"iPhoneRed0008.png"],
                                        [UIImage imageNamed:@"iPhoneRed0007.png"],
                                        [UIImage imageNamed:@"iPhoneRed0006.png"],
                                        [UIImage imageNamed:@"iPhoneRed0005.png"],
                                        nil];
            redCube2.animationDuration = .6;
            [redCube2 startAnimating];
        }

    }
    return self;
}

- (IBAction)presentGLView {
    [appDelegate.viewController showGLView];
}

- (IBAction)startGameAtGrid {
    appDelegate.glView.currentGrid = appDelegate.savedLastGridPlayed - 1;
    [appDelegate.viewController showGLView];
}
- (IBAction)presentControlSettings {
    [appDelegate.viewController showSettingsMenu];
}

- (IBAction)presentLeaderboard {
    [appDelegate.viewController showLeaderboard];
}

- (IBAction)presentPlayOptions {
    [appDelegate.viewController showPlayOptionsMenu];
}

@end
