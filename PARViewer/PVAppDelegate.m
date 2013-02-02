//
//  PVAppDelegate.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVAppDelegate.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"

@implementation PVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // fetch data that we want to revalidate from our cache
    [[ARManager shared] setApiKey:@"0d889de1-e1f9-4f5f-84fc-6c6f566b1866" andSecret:@"79cf5c70-ad89-4624-951f-2e2a2acfe413"];
    [[ARManager shared] restoreMARSState];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _contentControllers = [[NSMutableArray alloc] init];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTrendingSitesController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTechnologyViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVSearchViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVNearbySitesViewController alloc] init]]];
    
    // the sidebar controller automatically displays the items in the contentControllers array,
    // pulling images and titles from the tabBarItem and title of each controller.
    
    _sidebarController = [[PVSidebarViewController alloc] init];
    _slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController: [_contentControllers objectAtIndex: 0] backViewController: _sidebarController];
    _slidingViewController.delegate = self;

    self.window.rootViewController = _slidingViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [[ARManager shared] stashMARSState];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)switchToController:(int)index
{
    UIViewController * controller = [_contentControllers objectAtIndex: index];

    if ([_slidingViewController frontViewController] != controller)
        [_slidingViewController setFrontViewController:controller animated:YES completion:nil];
    
    [_slidingViewController closeSlider:YES completion:NULL];
}

@end
