//
//  Cube.h
//  Energize
//
//  Created by Todd Steinackle on 3/10/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"


@interface Cube : AbstractEntity {

    Animation *singleCube;
    Animation *doubleCube;
    bool isDoubleCube;
}

@property (assign, nonatomic) bool isDoubleCube;

- (id)initWithPixelLocation:(CGPoint)aLocation andAppearingDelay:(float)apDelay isDoubleCube:(BOOL)isDoubleCube;
- (void)changeAnimation;

@end
