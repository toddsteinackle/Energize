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
