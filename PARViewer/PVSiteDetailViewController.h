//
//  PVSiteDetailViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSite.h"
#import "PVParallaxTableView.h"

@interface PVSiteDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ARSite * site;

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PVParallaxTableView *parallaxView;

- (id)initWithSite:(ARSite *)site;

@end
