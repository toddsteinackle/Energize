//
//  MainMenuView.m

#import "MainMenuView.h"
#import "CubeStormAppDelegate.h"
#import "CubeStormViewController.h"

@implementation MainMenuView

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
        appDelegate = (CubeStormAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!appDelegate.gameCenterAvailable) {
            leaderboardButton.hidden = TRUE;
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
        }

    }
    return self;
}

- (IBAction)doGraphicsTest {
    [appDelegate.viewController showGLView];
}

- (IBAction)doMenuTest {
    [appDelegate.viewController showSettingsMenu];
}

- (IBAction)doLeaderboardTest {
    [appDelegate.viewController showLeaderboard];
}

@end
