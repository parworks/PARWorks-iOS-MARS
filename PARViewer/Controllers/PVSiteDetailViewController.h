//
//  PVSiteDetailViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSite.h"
#import "PVParallaxTableView.h"
#import "PVAddCommentViewController.h"
#import "GPUImageView.h"
#import "PVDetailsMapView.h"
#import "PVDetailsPhotoScrollView.h"

@interface PVSiteDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PVAddCommentViewControllerDelegate, PVDetailsMapViewDelegate>
{
    PVAddCommentViewController *_addCommentViewController;
    GPUImageView    * _bgCopyImageView;
}

@property (nonatomic, strong) ARSite * site;

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton * takePhotoButton;
@property (nonatomic, strong) PVParallaxTableView *parallaxView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) PVDetailsMapView *detailsMapView;
@property (nonatomic, strong) PVDetailsPhotoScrollView *detailsPhotoScrollView;

- (id)initWithSite:(ARSite *)site;

@end
