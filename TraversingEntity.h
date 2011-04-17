//
//  TraversingEntity.h
//  Energize
//
//  Created by Todd Steinackle on 4/5/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

typedef enum {
    te_top,
    te_bottom,
    te_right,
    te_left,
    te_top_left,
    te_top_right,
    te_bottom_left,
    te_bottom_right
} launchLocation;

@interface TraversingEntity : AbstractEntity {

    launchLocation launch_location;
    int frames;
}

- (void)movementWithDelta:(float)aDelta;
- (id)initLaunchLocationWithSpeed:(CGFloat)speed;

@end
