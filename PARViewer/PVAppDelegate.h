//
//  PVAppDelegate.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSSlidingViewController.h"
#import "PVTrendingSitesController.h"
#import "PVNearbySitesViewController.h"
#import "PVSearchViewController.h"
#import "PVTechnologyViewController.h"
#import "PVSidebarViewController.h"

@interface PVAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, JSSlidingViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JSSlidingViewController * slidingViewController;
@property (strong, nonatomic) NSMutableArray * contentControllers;
@property (strong, nonatomic) PVSidebarViewController * sidebarController;

- (void)switchToController:(int)index;

@end
