//
//  GLESGameState.m
//  Energize
//
//  Created by Todd Steinackle on 3/1/11.
//  Copyright 2011 The No Quarter Arcade. All rights reserved.
//

#import "GLESGameState.h"
#import "ES1Renderer.h"
#import "EnergizeAppDelegate.h"


@implementation GLESGameState

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)drawView:(id)sender {
    [renderer render];
}

- (void)layoutSubviews {
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        appDelegate = (EnergizeAppDelegate *)[[UIApplication sharedApplication] delegate];
        // Initialization code
        self.userInteractionEnabled = true;
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        if (appDelegate.retinaDisplay) {
            self.contentScaleFactor = 2.0;
            eaglLayer.contentsScale = 2.0;
        }

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];

        renderer = [[ES1Renderer alloc] init];

        if (!renderer)
        {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

- (void)updateSceneWithDelta:(float)aDelta { }
- (void)renderScene { }

@end
