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
#import "UIFont+ThemeAdditions.h"
#import "UINavigationBar+Additions.h"
#import "PVSiteDetailViewController.h"


NSString *const FBSessionStateChangedNotification = @"com.parworks.parviewer.Login:FBSessionStateChangedNotification";

@implementation PVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // fetch data that we want to revalidate from our cache
    [[ARManager shared] setApiKey:@"0d889de1-e1f9-4f5f-84fc-6c6f566b1866" andSecret:@"79cf5c70-ad89-4624-951f-2e2a2acfe413"];
    [[ARManager shared] restoreMARSState];
    [[ARManager shared] setLocationEnabled:YES];
        
    // setup appearance
    [self applyAppearanceSettingsWithin: [UINavigationController class]];
    [self applyAppearanceSettingsWithin: [UIToolbar class]];
    [self applyAppearanceSettingsWithin: [PVAddCommentViewController class]];        

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    
    _contentControllers = [[NSMutableArray alloc] init];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTrendingSitesController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVNearbySitesViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVSearchViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVScavengerHuntViewController alloc] init]]];
    [_contentControllers addObject: [[UINavigationController alloc] initWithRootViewController: [[PVTechnologyViewController alloc] init]]];
    
    for (UINavigationController * c in _contentControllers) {
        [[[c view] layer] setCornerRadius: 5];
        if ([[[c viewControllers] lastObject] isKindOfClass: [PVSearchViewController class]] == NO) {
            [[c navigationBar] addShadowEffect];
        }
    }
    
    // the sidebar controller automatically displays the items in the contentControllers array,
    // pulling images and titles from the tabBarItem and title of each controller.
    
    _sidebarController = [[PVSidebarViewController alloc] init];
    _slidingViewController = [[JSSlidingViewController alloc] initWithFrontViewController: [_contentControllers objectAtIndex: 0] backViewController: _sidebarController];
    _slidingViewController.useBouncyAnimations = NO;
    _slidingViewController.delegate = self;
    self.window.rootViewController = _slidingViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applyAppearanceSettingsWithin:(Class)class
{
    NSMutableDictionary * navigationTextAttributes = [NSMutableDictionary dictionary];
    UINavigationBar * navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: class, nil];
    [navigationTextAttributes setObject:[UIColor colorWithWhite:0.2 alpha:1] forKey: UITextAttributeTextColor];
    [navigationTextAttributes setObject:[UIFont parworksFontWithSize: 18] forKey: UITextAttributeFont];
    [navigationTextAttributes setObject:[UIColor whiteColor] forKey: UITextAttributeTextShadowColor];
    [navigationTextAttributes setObject:[NSValue valueWithCGPoint: CGPointMake(0,1)] forKey: UITextAttributeTextShadowOffset];
    [navigationBarAppearance setTitleTextAttributes: navigationTextAttributes];
    
    UIImage * navBarImage = [[UIImage imageNamed:@"navigation_bar_background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)];

    if(class == [UIToolbar class]){
        [[UIToolbar appearance] setBackgroundImage:navBarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [[UIToolbar appearance] setBackgroundImage:navBarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    }
    else{
        [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
        [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsLandscapePhone];    
    }
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
    
    if (FBSession.activeSession.isOpen && [self isSignedIntoFacebook]){
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
                 [self hideHUD];
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

- (BOOL)isSignedIntoFacebook{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isSignedIn = [defaults objectForKey:@"FBId"] && [[defaults objectForKey:@"FBId"] length] > 0;
    return isSignedIn;
}

- (void)showHUD:(NSString*)msg{
    [self setHUDMessage:msg];
}

- (void)hideHUD{
    [self setHUDMessage:nil];
}

- (void)HUDWasHidden:(MBProgressHUD *)HUD {
	// Remove HUD from screen when the HUD was hidden
	[_HUD removeFromSuperview];
	_HUD = nil;
}

- (void)setHUDMessage:(NSString*)message
{
    if (_HUD == nil && message != nil) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        _HUD = [MBProgressHUD showHUDAddedTo:_window animated:YES];
        _HUD.delegate = self;
        _HUD.labelText = message;
    }
    else if (_HUD && message != nil) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        _HUD.labelText = message;
    }
    else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [_HUD hide:YES];
    }
}

- (NSString*)HUDText{
    if(_HUD)
        return _HUD.labelText;
    else
        return nil;
}

- (void)showMessage:(NSString*)message whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion{
    if(_HUD && message){
        _HUD.labelText = message;
        [_HUD showAnimated:YES whileExecutingBlock:block completionBlock:completion];
    }
    else{
        [self hideHUD];
    }
}


@end
