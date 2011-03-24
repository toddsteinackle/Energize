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
    float appearingTimer, appearingDelay;
}

@property (nonatomic, readonly) CGPoint collisionBox;

- (id)initWithPixelLocation:(CGPoint)aLocation andAppearingDelay:(float)apDelay;

@end
