//
//  PVMapViewController.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/6/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVMapViewController.h"
#import "MapAnnotation.h"
#import "UINavigationItem+PVAdditions.h"
#import "UIColor+ThemeAdditions.h"

@interface PVMapViewController ()

@end

@implementation PVMapViewController

- (id)initWithSite:(ARSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupNavigationItem];
    
    MKCoordinateRegion region;
    region.center = _site.location;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    [_mapView setRegion:region];
    
    NSString *identifier = nil;
    
    if([_site.identifier length] > 0)
        identifier = _site.identifier;
    else
        identifier = @"No identifier available";
    
    NSString *address = nil;
    
    if([_site.address length] > 0)
        address = _site.address;
    else
        address = @"No address available";
    
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:_site.location andTitle:identifier andSubtitle:address];
    [_mapView addAnnotation:annotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationItem
{
    // Add the button in the upper left that opens the sidebar
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_back"] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_back_highlighted"] forState:UIControlStateHighlighted];
    customButton.frame = CGRectMake(0, 0, 57, 46);
    [customButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setUnpaddedLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:customButton] animated:NO];
    [self.navigationItem setLeftJustifiedTitle: _site.name];
    
    // Attach the "Augment Photo" icon to the upper right
    self.takePhotoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_takePhotoButton setBackgroundColor: [UIColor parworksSelectionBlue]];
    [_takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [_takePhotoButton.layer setAnchorPoint: CGPointMake(1, 0)];
    [_takePhotoButton setFrame: CGRectMake(0, 0, 100, 40)];
    
    UIView * takePhotoContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 100, 46)];
    CATransform3D t = takePhotoContainer.layer.transform;
    t.m34 = -0.0025;
    takePhotoContainer.layer.sublayerTransform = t;
    [takePhotoContainer addSubview: _takePhotoButton];
    [self.navigationItem setUnpaddedRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView: takePhotoContainer] animated:NO];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
