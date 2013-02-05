//
//  UINavigationController+BetterRotationBehavior.m
//  PARViewer
//
//  Created by Ben Gotow on 2/5/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UINavigationController+BetterRotationBehavior.h"

@implementation UINavigationController (BetterRotationBehavior)

- (BOOL)shouldAutorotate
{
    if ([self.topViewController respondsToSelector:@selector(shouldAutorotate)])
        return self.topViewController.shouldAutorotate;
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self.topViewController respondsToSelector: @selector(supportedInterfaceOrientations:)])
        return [self.topViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.topViewController respondsToSelector: @selector(shouldAutorotateToInterfaceOrientation:)])
        return [self.topViewController shouldAutorotateToInterfaceOrientation: interfaceOrientation];
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
