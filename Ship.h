//
//  Ship.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"


@interface Ship : AbstractEntity {

    Animation *teleporting;
    Animation *up;
    Animation *down;
    Animation *upThrust;
    Animation *downThrust;
    Animation *warp;
    Animation *right;
    Animation *left;
    Animation *rightThrust;
    Animation *leftThrust;

}

@end
