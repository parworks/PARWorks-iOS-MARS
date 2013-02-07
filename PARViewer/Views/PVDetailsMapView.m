//
//  PVDetailsMapView.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVDetailsMapView.h"
#import "ARSite+MARS_Extensions.h"
#import "MapAnnotation.h"
#import "UIFont+ThemeAdditions.h"

@implementation PVDetailsMapView

- (void)initialize{
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.mapButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_mapButton setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_mapButton];
    
    self.identifierLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_identifierLabel setBackgroundColor:[UIColor clearColor]];
    [_identifierLabel setUserInteractionEnabled:NO];
    [_identifierLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
    [_identifierLabel setFont:[UIFont parworksFontWithSize:18.0]];
    [_mapButton addSubview:_identifierLabel];
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_addressLabel setBackgroundColor:[UIColor clearColor]];
    [_addressLabel setUserInteractionEnabled:NO];
    [_addressLabel setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
    [_addressLabel setFont:[UIFont parworksFontWithSize:12.0]];
    [_mapButton addSubview:_addressLabel];
    
    self.mapContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_mapContainerView setBackgroundColor:[UIColor clearColor]];
    [self addSubview: _mapContainerView];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [_mapView setBackgroundColor:[UIColor clearColor]];
    [_mapView setDelegate:self];
    [_mapView setUserInteractionEnabled:NO];
    [_mapContainerView addSubview:_mapView];
    
    self.mapShadowButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_mapShadowButton addTarget:self action:@selector(mapViewPressed) forControlEvents:UIControlEventTouchUpInside];
    [_mapShadowButton setImage:[UIImage imageNamed:@"map_inner_shadow.png"] forState: UIControlStateNormal];
    [_mapShadowButton setImage:[UIImage imageNamed:@"map_inner_shadow_highlighted.png"] forState: UIControlStateHighlighted];
    [_mapContainerView addSubview:_mapShadowButton];
    
}

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
        [self setFrame:rect];
    }
    return self;
}

- (id)initWithSite:(ARSite*)site{
    if(self = [self initWithFrame:CGRectZero]){
        self.site = site;
        if([_site.identifier length] > 0)
            _identifierLabel.text = _site.identifier;
        else
            _identifierLabel.text = @"No identifier available";
        
        if([_site.address length] > 0)
            _addressLabel.text = _site.address;
        else
            _addressLabel.text = @"No address available";
        
        if(_site.location.latitude == 0.0 && _site.location.latitude == 0.0){
            [_mapContainerView setHidden:YES];
        } else {
            [_mapContainerView setHidden:NO];
            MKCoordinateRegion region;
            region.center = _site.location;
            region.span.latitudeDelta = 0.005;
            region.span.longitudeDelta = 0.005;
            [_mapView setRegion:region];
            
            MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:_site.location andTitle:_identifierLabel.text andSubtitle:_addressLabel.text];
            [_mapView addAnnotation:annotation];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_mapButton setFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 63.0)];
    [_identifierLabel setFrame:CGRectMake(10.0, 10.0, _mapButton.frame.size.width - 20.0, 24.0)];
    [_addressLabel setFrame:CGRectMake(_identifierLabel.frame.origin.x, _identifierLabel.frame.origin.y + _identifierLabel.frame.size.height - 4.0, _identifierLabel.frame.size.width, 20.0)];
    
    [_mapContainerView setFrame:CGRectMake(10.0, _mapButton.frame.origin.y + _mapButton.frame.size.height, self.frame.size.width - 20.0, 100.0)];
    [_mapView setFrame:_mapContainerView.bounds];
    [_mapShadowButton setFrame:_mapContainerView.bounds];
}

- (void)mapViewPressed
{
    [_delegate mapViewPressed];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if (annotation == mapView.userLocation)
        return nil;
    else{
        static NSString *AnnotationReuseIdentifier = @"AnnotationReuseIdentifier";
        
        MKAnnotationView *annotationView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationReuseIdentifier];
        if(annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationReuseIdentifier];
            annotationView.image = [UIImage imageNamed:@"map_marker.png"];
            annotationView.centerOffset = CGPointMake(1.0, -14.0);
        }
        
        return annotationView;
    }
}

@end
