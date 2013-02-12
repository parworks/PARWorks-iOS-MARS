//
//  PVScavengerHuntViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 2/11/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVBaseViewController.h"

@interface PVScavengerHuntViewController : PVBaseViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
