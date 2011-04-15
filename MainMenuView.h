//
//  MainMenuView.h

#import <Foundation/Foundation.h>

@class CubeStormAppDelegate;

@interface MainMenuView : UIView {
    IBOutlet UIView *subview;
    CubeStormAppDelegate *appDelegate;
    IBOutlet UIButton *leaderboardButton;
    IBOutlet UIImageView *purpleCube;
    IBOutlet UIImageView *redCube;
    IBOutlet UIImageView *purpleCube2;
    IBOutlet UIImageView *redCube2;
}


- (IBAction)doGraphicsTest;
- (IBAction)doMenuTest;
- (IBAction)doLeaderboardTest;

@end
