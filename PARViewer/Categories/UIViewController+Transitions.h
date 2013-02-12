//
//  UIViewController+Transitions.h
//  CameraTransitionTest
//
//  Created by Demetri Miller on 2/10/13.
//  Copyright (c) 2013 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUIViewController_PeelTransitionsAnimationDuration 10.0

@interface UIViewController (Transitions)

- (void)peelPresentViewController:(UIViewController *)viewControllerToPresent withContentImage:(UIImage *)contentImage depthImage:(UIImage *)depthImage;

@end
