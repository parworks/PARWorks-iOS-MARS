//
//  PVDetailsMapView.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ARSite.h"

@protocol PVDetailsMapViewDelegate;

@interface PVDetailsMapView : UIView<MKMapViewDelegate>

@property (nonatomic, weak) id<PVDetailsMapViewDelegate> delegate;
@property (nonatomic, strong) ARSite *site;
@property (nonatomic, strong) UILabel *identifierLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) UIView *mapContainerView;
@property (nonatomic, strong) UIButton *mapShadowButton;
@property (nonatomic, strong) MKMapView *mapView;

- (id) initWithSite:(ARSite*)site;

@end

@protocol PVDetailsMapViewDelegate <NSObject>

@required
- (void)mapViewPressed;
@end