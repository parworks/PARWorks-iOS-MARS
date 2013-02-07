//
//  PVNearbySitesViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBaseViewController.h"
#import "PVParallaxTableView.h"
#import <MapKit/MapKit.h>

@interface PVNearbySitesViewController : PVBaseViewController<UITableViewDataSource, UITableViewDelegate, PVParallaxTableViewDelegate, MKMapViewDelegate>{
    CLLocationCoordinate2D centerCoordinate;
    MKCoordinateRegion region;
    BOOL bLoadedOnce;
    NSTimer *_panTimer;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton * mapCollapseButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PVParallaxTableView *parallaxView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) NSArray *nearbySites;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) UIButton *mapRefreshButton;
@property (nonatomic, strong) UIButton *mapRecenterButton;

@end
