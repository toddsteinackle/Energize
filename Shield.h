//
//  Shield.h
//  CubeStorm
//
//  Created by Todd Steinackle on 3/26/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

@class Ship;

@interface Shield : AbstractEntity {

    Ship *ship;
    float duration;
}

@property (assign, nonatomic) float duration;

- (id)initWithPixelLocation:(CGPoint)aLocation containingShip:(Ship *)shipId;

@end
