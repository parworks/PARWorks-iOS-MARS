//
//  PVMapViewController.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/6/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ARSite.h"

@interface PVMapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic, strong) ARSite * site;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UIButton * takePhotoButton;

- (id)initWithSite:(ARSite *)site;

@end
