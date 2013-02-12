//
//  UIViewController+Transitions.m
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/10/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIViewController+Transitions.h"



@implementation UIViewController (Transitions)

- (void)peelPresentViewController:(UIViewController *)viewControllerToPresent withContentImage:(UIImage *)contentImage depthImage:(UIImage *)depthImage
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    CGFloat windowOffset;
    CGRect bounds;
    if (self.navigationController) {
        windowOffset = 0;
        bounds = self.navigationController.view.bounds;
    } else {
        windowOffset = 20;
        bounds = self.view.bounds;
    }
    CALayer *mainLayer = [CALayer layer];
    mainLayer.frame = bounds;
    mainLayer.backgroundColor = [UIColor clearColor].CGColor;
    mainLayer.anchorPoint = CGPointMake(0, 0.5);
    mainLayer.position = CGPointMake(0, (bounds.size.height/2) + windowOffset);
    [mainWindow.layer addSublayer:mainLayer];
    
    CATransformLayer *transformLayer = [CATransformLayer layer];
    [mainLayer addSublayer:transformLayer];
    
    CALayer *contentsLayer = [CALayer layer];
    contentsLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    contentsLayer.contentsGravity = kCAGravityResize;
    contentsLayer.contents = (id)contentImage.CGImage;
    [transformLayer addSublayer:contentsLayer];
    
    CAGradientLayer *contentsShadowLayer = [CAGradientLayer layer];
    contentsShadowLayer.frame = contentsLayer.bounds;
    contentsShadowLayer.colors = [NSArray arrayWithObjects: (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor], nil];
    contentsShadowLayer.startPoint = CGPointMake(0, 0);
    contentsShadowLayer.endPoint = CGPointMake(1, 0);
    contentsShadowLayer.opacity = 0.0;
    [contentsLayer addSublayer:contentsShadowLayer];
    
    CATransform3D depthTransform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    depthTransform.m34 = -1.0/500.0;
    CALayer *depthLayer = [CALayer layer];
    depthLayer.anchorPoint = CGPointMake(0, 0.5);
    depthLayer.bounds = CGRectMake(0, 0, 24, bounds.size.height);
    depthLayer.position = CGPointMake(bounds.size.width, bounds.size.height/2);
    depthLayer.transform = depthTransform;
    depthLayer.zPosition = 0;
    depthLayer.contents = (id)depthImage.CGImage;
    //    _depthLayer.contentsGravity = kCAGravityResize;
    [transformLayer addSublayer:depthLayer];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self startAnimationWithMainLayer:mainLayer contentsShadowLayer:contentsShadowLayer presentVC:viewControllerToPresent];
    });
}

- (void)startAnimationWithMainLayer:(CALayer *)mainLayer contentsShadowLayer:(CALayer *)contentsShadowLayer presentVC:(UIViewController *)vc
{
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -1.0/500.0;
    t = CATransform3DTranslate(t, -24, 0, 0);
    t = CATransform3DRotate(t, 3*M_PI_2, 0, 1, 0);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:kUIViewController_PeelTransitionsAnimationDuration];
    //    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    mainLayer.sublayerTransform = t;
    contentsShadowLayer.opacity = 1.0;
    [CATransaction commit];
    
    double delayInSeconds = kUIViewController_PeelTransitionsAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:vc animated:NO completion:nil];
    });
}

@end
