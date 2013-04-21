//
//  PVSlidingViewController.m
//  PARViewer
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

#import "PVSlidingViewController.h"
#import "PVIntroViewController.h"

#define kDefaultsHasPerformedFirstLaunchKey @"kDefaultsHasPerformedFirstLaunchKey"

@implementation PVSlidingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    BOOL hasPerformedFirstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsHasPerformedFirstLaunchKey];
    if (!hasPerformedFirstLaunch)
        [self showIntroControllerAnimated:NO];
}

- (void)showIntroControllerAnimated:(BOOL)animated
{    
    PVIntroViewController *iv = [[PVIntroViewController alloc] initWithNibName:@"PVIntroViewController" bundle:nil];
    [self addChildViewController:iv];
    [iv.view setFrame: self.view.bounds];
    [self.view addSubview:iv.view];
    
    CGPoint center = iv.view.center;
    CGFloat scaleX = 57/self.view.bounds.size.width;
    CGFloat scaleY = 46/self.view.bounds.size.height;
    CGAffineTransform t = CGAffineTransformMakeScale(scaleX, scaleY);
    
    CGFloat duration = animated ? 0.4 : 0.0;
    iv.view.center = CGPointMake(self.view.bounds.size.width - (57/2.0), (46/2));
    iv.view.alpha = 0.0;
    iv.view.transform = t;
    [UIView animateWithDuration:duration animations:^{
        iv.view.alpha = 1.0;
        iv.view.transform = CGAffineTransformMakeScale(1, 1);
        iv.view.center = center;
    } completion:^(BOOL finished) {
        [iv didMoveToParentViewController:self];
    }];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsHasPerformedFirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
