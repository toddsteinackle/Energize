//
//  MainMenuView.h

#import <Foundation/Foundation.h>

@class CubeStormAppDelegate;

@interface MainMenuView : UIView {
    IBOutlet UIView* subview;
    CubeStormAppDelegate *appDelegate;
    IBOutlet UIButton* leaderboardButton;
}

- (IBAction)doGraphicsTest;
- (IBAction)doMenuTest;
- (IBAction)doLeaderboardTest;

@end
