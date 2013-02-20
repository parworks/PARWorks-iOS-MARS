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
