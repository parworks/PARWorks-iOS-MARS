//
//  PVDetailsMapView.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ARSite.h"

@interface PVDetailsMapView : UIView<MKMapViewDelegate>

@property (nonatomic, strong) ARSite *site;
@property (nonatomic, strong) UILabel *identifierLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) MKMapView *mapView;

- (id) initWithSite:(ARSite*)site;

@end
