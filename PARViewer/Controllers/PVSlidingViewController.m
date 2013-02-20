//
//  PVSlidingViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/19/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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
    
    CGFloat duration = animated ? 0.5 : 0.0;
    iv.view.alpha = 0.0;
    iv.view.transform = CGAffineTransformMakeScale(2, 2);
    [UIView animateWithDuration:duration animations:^{
        iv.view.alpha = 1.0;
        iv.view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [iv didMoveToParentViewController:self];
    }];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsHasPerformedFirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
