//
//  UINavigationController+BetterRotationBehavior.m
//  MARS
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
