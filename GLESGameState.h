//
//  GLESGameState.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESRenderer.h"

@class CubeStormAppDelegate;

@interface GLESGameState : UIView {

    CubeStormAppDelegate *appDelegate;

@private
    id <ESRenderer> renderer;

}

- (id)initWithFrame:(CGRect)frame;
- (void)renderScene;
- (void)updateSceneWithDelta:(float)aDelta;
- (void)drawView:(id)sender;

@end
