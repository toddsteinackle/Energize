//
//  MainMenuView.h

#import <Foundation/Foundation.h>

@class CubeStormAppDelegate;

@interface MainMenuView : UIView {
    IBOutlet UIView *subview;
    CubeStormAppDelegate *appDelegate;
    IBOutlet UIButton *newGameButton;
    IBOutlet UIButton *startAtGridButton;
    IBOutlet UIButton *playSettingsButton;
    IBOutlet UIButton *controlSettingsButton;
    IBOutlet UIButton *helpButton;
    IBOutlet UIButton *aboutButton;
    IBOutlet UIButton *leaderboardButton;
    IBOutlet UIButton *achievementButton;
    IBOutlet UIImageView *purpleCube;
    IBOutlet UIImageView *redCube;
    IBOutlet UIImageView *purpleCube2;
    IBOutlet UIImageView *redCube2;
}


- (IBAction)presentGLView;
- (IBAction)presentControlSettings;
- (IBAction)presentLeaderboard;
- (IBAction)presentPlayOptions;

@end
