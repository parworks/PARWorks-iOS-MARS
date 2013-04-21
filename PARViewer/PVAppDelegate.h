//
//  PVAppDelegate.h
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