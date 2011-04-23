//
//  AboutMenuViewController.h
//  Energize
//
//  Created by Todd Steinackle on 4/22/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EnergizeAppDelegate;
@class SoundManager;

@interface AboutMenuViewController : UIViewController {
    EnergizeAppDelegate *appDelegate;
    SoundManager *sharedSoundManager;
}

- (IBAction)dismiss;

@end
