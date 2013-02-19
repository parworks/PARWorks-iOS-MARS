//
//  PVAppDelegate.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVSlidingViewController.h"
#import "UINavigationController+BetterRotationBehavior.h"
#import "PVTrendingSitesController.h"
#import "PVNearbySitesViewController.h"
#import "PVSearchViewController.h"
#import "PVTechnologyViewController.h"
#import "PVScavengerHuntViewController.h"
#import "PVSidebarViewController.h"
#import "FacebookSDK.h"
#import "MBProgressHUD.h"
#import "UAPush.h"
#import "UAirship.h"


extern NSString *const FBSessionStateChangedNotification;

@interface PVAppDelegate : UIResponder <UAPushNotificationDelegate, UIApplicationDelegate, UITabBarControllerDelegate, JSSlidingViewControllerDelegate, MBProgressHUDDelegate>{
    MBProgressHUD *_HUD;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PVSlidingViewController * slidingViewController;
@property (strong, nonatomic) NSMutableArray * contentControllers;
@property (strong, nonatomic) PVSidebarViewController * sidebarController;

+ (BOOL)isiPhone5;

- (void)switchToController:(int)index;
- (BOOL)authorizeFacebook:(BOOL)allowLoginUI;
- (void)logoutFacebook;
- (BOOL)isSignedIntoFacebook;

- (void)showHUD:(NSString*)msg;
- (void)hideHUD;
- (void)showMessage:(NSString*)message whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion;


@end

#define FACEBOOK_APP_ID              @"410586319030328"
#define NOTIF_FACEBOOK_INFO_REQUEST  @"NOTIF_FACEBOOK_INFO_REQUEST"
#define NOTIF_FACEBOOK_LOGGED_IN     @"NOTIF_FACEBOOK_LOGGED_IN"