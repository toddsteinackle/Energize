//
//  MainMenuView.h

#import <Foundation/Foundation.h>

@class EnergizeAppDelegate;

@interface MainMenuView : UIView {
    IBOutlet UIView *subview;
    EnergizeAppDelegate *appDelegate;
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

@property (nonatomic, retain) UIButton *startAtGridButton;

- (IBAction)presentGLView;
- (IBAction)presentControlSettings;
- (IBAction)presentLeaderboard;
- (IBAction)presentAchievements;
- (IBAction)presentPlayOptions;
- (IBAction)startGameAtGrid;
- (IBAction)presentAbout;
- (IBAction)presentHelp;

@end
