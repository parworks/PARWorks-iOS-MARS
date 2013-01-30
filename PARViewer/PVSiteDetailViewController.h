//
//  PVSiteDetailViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSite.h"

@interface PVSiteDetailViewController : UIViewController

@property (nonatomic, retain) ARSite * site;

- (id)initWithSite:(ARSite *)site;

@end
