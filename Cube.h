//
//  Cube.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"


@interface Cube : AbstractEntity {

    CGPoint collisionBox;
}

@property (nonatomic, readonly) CGPoint collisionBox;

@end
