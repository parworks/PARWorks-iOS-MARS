//
//  PVNearbySitesViewController.h
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

#import "PVBaseViewController.h"
#import "PVParallaxTableView.h"
#import <MapKit/MapKit.h>
#import "PVButton.h"

@interface PVNearbySitesViewController : PVBaseViewController<UITableViewDataSource, UITableViewDelegate, PVParallaxTableViewDelegate, MKMapViewDelegate>{
    CLLocationCoordinate2D centerCoordinate;
    MKCoordinateRegion region;
    BOOL bLoadedOnce;
    NSTimer *_panTimer;
    BOOL _firstNearbySitesLoadOccurred;
}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton * mapCollapseButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PVParallaxTableView *parallaxView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) NSArray *nearbySites;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) UIButton *mapRefreshButton;
@property (nonatomic, strong) PVButton *mapRecenterButton;

@end
