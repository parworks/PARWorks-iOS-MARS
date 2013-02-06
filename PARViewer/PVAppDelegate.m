//
//  PVAppDelegate.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <SparkInspector/SparkInspector.h>
#import "PVAppDelegate.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"
#import "UIFont+ThemeAdditions.h"

NSString *const FBSessionStateChangedNotification = @"com.parworks.parviewer.Login:FBSessionStateChangedNotification";

@implementation PVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Enable the Spark Inspector
//    [SparkInspector enableObservation];

    // fetch data that we want to revalidate from our cache
    [[ARManager shared] setApiKey:@"0d889de1-e1f9-4f5f-84fc-6c6f566b1866" andSecret:@"79cf5c70-ad89-4624-951f-2e2a2acfe413"];
    [[ARManager shared] restoreMARSState];
    [[ARManager shared] setLocationEnabled:YES];
    
    // setup appearance
    NSMutableDictionary * navigationTextAttributes = [NSMutableDictionary dictionary];
    UINavigationBar * navigationBarAppearance = [UINavigationBar appearance];
    [navigationTextAttributes setObject:[UIColor colorWithWhite:0.2 alpha:1] forKey: UITextAttributeTextColor];
    [navigationTextAttributes setObject:[UIFont parworksFontWithSize: 18] forKey: UITextAttributeFont];
    [navigationTextAttributes setObject:[UIColor whiteColor] forKey: UITextAttributeTextShadowColor];
    [navigationTextAttributes setObject:[NSValue valueWithCGPoint: CGPointMake(0,1)] forKey: UITextAttributeTextShadowOffset];
    [navigationBarAppearance setTitleTextAttributes: navigationTextAttributes];
    
    UIBarButtonItem * barButtonItemAppearance = [UIBarButtonItem appearance];
    
    NSMutableDictionary * barButtonItemTextAttributes = [NSMutableDictionary dictionary];
    [barButtonItemTextAttributes setObject:[UIColor colorWithWhite:0.2 alpha:1] forKey: UITextAttributeTextColor];
    [barButtonItemTextAttributes setObject:[UIFont parworksFontWithSize: 12] forKey: UITextAttributeFont];
    [barButtonItemTextAttributes setObject:[UIColor whiteColor] forKey: UITextAttributeTextShadowColor];
    [barButtonItemTextAttributes setObject:[NSValue valueWithCGPoint: CGPointMake(0,1)] forKey: UITextAttributeTextShadowOffset];

    [barButtonItemAppearance setTitleTextAttributes:barButtonItemTextAttributes forState:UIControlStateNormal];
    
    [barButtonItemAppearance setTintColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]];
    [barButtonItemAppearance setTitlePositionAdjustment:UIOffsetMake(0.0, 3.0) forBarMetrics:UIBarMetricsDefault];
    
    UIImage * navBarImage = [[UIImage imageNamed:@"navigation_bar_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)];
    [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    
    _contentControllers = [[NSMutableArray alloc] init];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTrendingSitesController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVNearbySitesViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVSearchViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTechnologyViewController alloc] init]]];
    
    for (UINavigationController * c in _contentControllers) {
        [[[c view] layer] setCornerRadius: 5];
        if ([[[c viewControllers] lastObject] isKindOfClass: [PVSearchViewController class]] == NO) {
            [[[c navigationBar] layer] setShadowRadius: 3];
            [[[c navigationBar] layer] setShadowOffset: CGSizeMake(0, 1)];
            [[[c navigationBar] layer] setShadowOpacity: 0.3];
        }
    }
    
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
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)switchToController:(int)index
{
    UIViewController * controller = [_contentControllers objectAtIndex: index];

    if (![_slidingViewController animating]) {
        if ([_slidingViewController frontViewController] != controller)
            [_slidingViewController setFrontViewController:controller animated:YES completion:^{
                [controller viewDidAppear: YES];
            }];
        [_slidingViewController closeSlider:YES completion:NULL];
    }
}



#pragma mark
#pragma mark Facebook methods



/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                //Log(@"User session found");
                [self fbDidLogin];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            [self fbDidLogout];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        NSLog(@"Error code: %d", error.code);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Facebook cannot be accessed until you give permission. Go to Settings > Privacy > Facebook to reset."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */

- (BOOL)authorizeFacebook:(BOOL)allowLoginUI{
    return [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"email", nil]
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

- (void)logoutFacebook{
    [FBSession.activeSession closeAndClearTokenInformation];
    [self fbDidLogout];
}

- (void)fbDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FACEBOOK_INFO_REQUEST object:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[FBSession.activeSession accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[FBSession.activeSession expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    if (FBSession.activeSession.isOpen && [defaults objectForKey:@"FBId"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FACEBOOK_LOGGED_IN object:@"YES"];
    }    
    else if (FBSession.activeSession.isOpen) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 if ([user isKindOfClass:[NSDictionary class]]){
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:[user objectForKey:@"name"] forKey:@"FBName"];
                     [defaults setObject:[user objectForKey:@"email"] forKey:@"FBEmail"];
                     [defaults setObject:[user objectForKey:@"id"] forKey:@"FBId"];
                     [defaults synchronize];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FACEBOOK_LOGGED_IN object:@"YES"];
             }
             else{
                 NSLog(@"Error code: %d", error.code);
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                 message:@"Facebook cannot be accessed until you give permission. Go to Settings > Privacy > Facebook to reset."
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }];
    }
}


- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults removeObjectForKey:@"FBName"];
        [defaults removeObjectForKey:@"FBEmail"];
        [defaults removeObjectForKey:@"FBLocation"];
        [defaults removeObjectForKey:@"FBId"];
        [defaults synchronize];
    }
}



@end
