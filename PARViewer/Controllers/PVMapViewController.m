//
//  PVMapViewController.m
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
    
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithSite:_site];
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
            annotationView.canShowCallout = YES;    
        }
                        
        return annotationView;
    }
}

@end
