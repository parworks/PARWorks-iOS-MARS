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
        [self showIntroController];
}

- (void)showIntroController
{
    PVIntroViewController *iv = [[PVIntroViewController alloc] initWithNibName:@"PVIntroViewController" bundle:nil];
    [self addChildViewController:iv];
    [iv.view setFrame: self.view.bounds];
    [self.view addSubview:iv.view];
    [iv didMoveToParentViewController:self];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsHasPerformedFirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
