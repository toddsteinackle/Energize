//
//  TraversingEntity.h
//  CubeStorm
//
//  Created by Todd Steinackle on 4/5/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

typedef enum {
    te_top,
    te_bottom,
    te_right,
    te_left
} launchLocation;

@interface TraversingEntity : AbstractEntity {

    launchLocation launch_location;
    int frames;
}

- (void)movementWithDelta:(float)aDelta;

@end
