//
//  PVNearbySitesViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVNearbySitesViewController.h"
#import "ARManager+MARS_Extensions.h"
#import "PVSiteDetailViewController.h"
#import "PVSiteTableViewCell.h"
#import "MapAnnotation.h"
#import "UIFont+ThemeAdditions.h"
#import "UINavigationItem+PVAdditions.h"

#define PARALLAX_WINDOW_HEIGHT 165.0
#define PARALLAX_IMAGE_HEIGHT 300.0
#define NEARBY_SEARCH_RADIUS 1600.0

@interface PVNearbySitesViewController ()

@end

@implementation PVNearbySitesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Nearby", @"Nearby");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_nearby"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.annotations = [NSMutableArray array];
    
    // Do any additional setup after loading the view from its nib.
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PARALLAX_IMAGE_HEIGHT)];
    _mapView.contentMode = UIViewContentModeScaleAspectFill;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    self.mapRecenterButton = [[PVButton alloc] init];
    [_mapRecenterButton setFrame:CGRectMake(10.0, 10.0, 46, 42)];
    [_mapRecenterButton setAlpha:0.0];
    [_mapRecenterButton addTarget:self action:@selector(findNearbySites) forControlEvents:UIControlEventTouchUpInside];
    [_mapRecenterButton setImage:[UIImage imageNamed:@"map_icon_recenter.png"] forState:UIControlStateNormal];
    [_mapView addSubview:_mapRecenterButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self setupTableHeaderView];
    [self setupMapRefreshButton];
    
    self.parallaxView = [[PVParallaxTableView alloc] initWithBackgroundView:_mapView
                                                        foregroundTableView:_tableView
                                                               windowHeight:PARALLAX_WINDOW_HEIGHT];
    _parallaxView.delegate = self;
    _parallaxView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].applicationFrame.size.height - self.navigationController.navigationBar.frame.size.height);
    _parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _parallaxView.backgroundColor = [UIColor clearColor];
    [_parallaxView setTableHeaderView:_tableHeaderView headerExpansionEnabled:YES];
    [_parallaxView setLocalDelegate:self];
    [self.view addSubview:_parallaxView];
    
    [self findNearbySites];
}

- (void)setupTableHeaderView{
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
    [_tableHeaderView setBackgroundColor:[UIColor whiteColor]];
}

- (void)setupMapRefreshButton{
    _mapRefreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mapRefreshButton setBackgroundImage:[UIImage imageNamed:@"bar_item_reload"] forState:UIControlStateNormal];
    [_mapRefreshButton setBackgroundImage:[UIImage imageNamed:@"bar_item_reload_highlighted"] forState:UIControlStateHighlighted];
    _mapRefreshButton.frame = CGRectMake(0, 0, 57, 46);
    [_mapRefreshButton addTarget:self action:@selector(findNearbySites) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * refresh = [[UIBarButtonItem alloc] initWithCustomView: _mapRefreshButton];
    [self.navigationItem setUnpaddedRightBarButtonItem:refresh animated: NO];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_nearbySites count] == 0)
        return 1;
    else
        return [_nearbySites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_nearbySites count] == 0){
        UITableViewCell *c = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        if (!c){
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCell"];
            [c.contentView setBackgroundColor: [UIColor whiteColor]];
            [c setSelectionStyle: UITableViewCellSelectionStyleNone];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, c.contentView.frame.size.width-20, 48.0)];
            [label setFont:[UIFont parworksFontWithSize:18.0]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
            [label setNumberOfLines:0];
            
            if ([CLLocationManager locationServicesEnabled]) {
                [label setText:@"Enable location services to view nearby sites."];
            } else {
                [label setText:@"No sites nearby."];
            }

            [c.contentView addSubview:label];
        }
        
        return c;
    }
    else{
        PVSiteTableViewCell * c = (PVSiteTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"siteCell"];
        if (!c)
            c = [[PVSiteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"siteCell"];
        ARSite * site = [_nearbySites objectAtIndex: [indexPath row]];
        [c setSite: site];
        return c;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if([_nearbySites count] > 0){
        ARSite * site = [_nearbySites objectAtIndex: [indexPath row]];
        PVSiteDetailViewController * siteDetailController = [[PVSiteDetailViewController alloc] initWithSite: site];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:siteDetailController] animated:YES completion:NULL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220.0;
}

- (void)closeMap
{
    [_parallaxView windowButtonPressed];
}

#pragma mark
#pragma mark PVParallaxTableViewDelegate methods

- (void)windowButtonPressed:(BOOL)isExpanded
{
    if(isExpanded){
        [self setupMapRefreshButton];
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            [_mapRecenterButton setAlpha:0.0];
            [_mapCollapseButton setAlpha: 0.0];
        } completion:nil];
    }
    else{
        _mapCollapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mapCollapseButton setBackgroundImage:[UIImage imageNamed:@"bar_item_up"] forState:UIControlStateNormal];
        [_mapCollapseButton setBackgroundImage:[UIImage imageNamed:@"bar_item_up_highlighted"] forState:UIControlStateHighlighted];
        _mapCollapseButton.frame = CGRectMake(0, 0, 57, 46);
        [_mapCollapseButton addTarget:self action:@selector(closeMap) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * collapse = [[UIBarButtonItem alloc] initWithCustomView: _mapCollapseButton];
        [self.navigationItem setUnpaddedRightBarButtonItem:collapse animated: NO];
        
        [_mapRecenterButton setFrame:CGRectMake(_mapRecenterButton.frame.origin.x, _mapView.frame.size.height - _mapRecenterButton.frame.size.height - 10.0, _mapRecenterButton.frame.size.width, _mapRecenterButton.frame.size.height)];
        
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            [_mapRecenterButton setAlpha:1.0];
        } completion:nil];
    }
    [_mapView setRegion:region animated:YES];
}

- (void)refetchAnnotations:(BOOL)needsCentering
{
    NSMutableArray *toRemove = [NSMutableArray array];
    for (id annotation in _mapView.annotations){
        if (annotation != _mapView.userLocation)
            [toRemove addObject:annotation];
    }
    [_mapView removeAnnotations:toRemove];
    
    [self loadAnnotationsFromStorage:needsCentering];
}

- (void)loadAnnotationsFromStorage:(BOOL)needsCentering
{
	// add a map annotation for each item's location
    
    if([_nearbySites count] > 0){
        [self.annotations removeAllObjects];
        
        // set up min/max coordinate values to something ridiculous that will be overwritten.
        CLLocationCoordinate2D topLeftCoordinate;
        topLeftCoordinate.latitude = -90;
        topLeftCoordinate.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoordinate;
        bottomRightCoordinate.latitude = 90;
        bottomRightCoordinate.longitude = -180;
        
        double prevLat = _mapView.userLocation.location.coordinate.latitude;
        double prevLon = _mapView.userLocation.location.coordinate.longitude;
        
        for (int i=0; i < [_nearbySites count]; i++) {
            ARSite *site = [_nearbySites objectAtIndex:i];
            
            if (site.location.latitude != 0.000000 &&  site.location.longitude != 0.000000){
                
                double latDiff = 0.0;
                double lonDiff = 0.0;
                
                if(prevLat != 0.0 && prevLon != 0.0){
                    latDiff = site.location.latitude - prevLat;
                    lonDiff = site.location.longitude - prevLon;
                    
                    if(latDiff < 0.0)
                        latDiff = latDiff * -1;
                    if(lonDiff < 0.0)
                        lonDiff = lonDiff * -1;
                }
                
                prevLat = site.location.latitude;
                prevLon = site.location.longitude;
                
                if(latDiff < 0.1 && lonDiff < 0.1){
                    // update min/max
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, site.location.latitude);
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, site.location.longitude);
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, site.location.latitude);
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, site.location.longitude);
                }
                
                MapAnnotation *annotation = [[MapAnnotation alloc] initWithSite:site];
                [_mapView addAnnotation:annotation];
                [self.annotations addObject:annotation];
            }
            
            
        }
        
        centerCoordinate.latitude = (topLeftCoordinate.latitude + bottomRightCoordinate.latitude)/2.0;
        centerCoordinate.longitude = (topLeftCoordinate.longitude + bottomRightCoordinate.longitude)/2.0;
        
        if(!bLoadedOnce){
            region.center = centerCoordinate;
            double latDelta = (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) + 0.001;
            double lonDelta = (topLeftCoordinate.longitude - bottomRightCoordinate.longitude) + 0.001;
            
            if(latDelta < 0.0)
                latDelta = latDelta * -1;
            if(lonDelta < 0.0)
                lonDelta = lonDelta * -1;
            
            region.span.latitudeDelta = latDelta;
            region.span.longitudeDelta = lonDelta;
            if(needsCentering)
                [_mapView setRegion:region animated:YES];
        }
        
        
        if ([self.annotations count] > 0) {
            [_mapView addAnnotations:self.annotations];
        }
        bLoadedOnce = YES;
    }
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
        
        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        disclosureButton.frame = CGRectMake(0, 0, 23, 23);
        disclosureButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        disclosureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        annotationView.rightCalloutAccessoryView = disclosureButton;
        
        return annotationView;
    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    ARSite * site = (ARSite*)[[self.annotations objectAtIndex:[self.annotations indexOfObjectIdenticalTo:view.annotation]] valueForKey:@"_site"];    
    PVSiteDetailViewController * siteDetailController = [[PVSiteDetailViewController alloc] initWithSite: site];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:siteDetailController] animated:YES completion:NULL];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(_panTimer){
        [_panTimer invalidate];
        _panTimer = nil;
    }
    
    _panTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(findSites:)
                                               userInfo:nil
                                                repeats:NO];
}

- (void)findNearbySites
{
    [_mapRecenterButton setIsAnimating:YES];
    __weak PVNearbySitesViewController *__self = self;
    [[ARManager shared] findNearbySites:NEARBY_SEARCH_RADIUS withCompletionBlock:^(NSArray* sites, CLLocation * location){
        __self.nearbySites = sites;
        bLoadedOnce = NO;
        [__self refetchAnnotations:YES];
        [__self.tableView reloadData];
        [__self.mapRecenterButton setIsAnimating:NO];
    }];
}

- (void)findSites:(NSTimer*)theTimer{
    if([_parallaxView isExpanded]){
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:_mapView.region.center.latitude longitude:_mapView.region.center.longitude];
        [_mapRecenterButton setIsAnimating:YES];
        __weak PVNearbySitesViewController *__self = self;
        [[ARManager shared] findSites:NEARBY_SEARCH_RADIUS nearLocation:currentLocation withCompletionBlock:^(NSArray* sites, CLLocation * location){
            if(location.coordinate.latitude == __self.mapView.region.center.latitude && location.coordinate.longitude == __self.mapView.region.center.longitude){
                NSLog(@"Setting Nearby Sites...");
                __self.nearbySites = sites;
                bLoadedOnce = NO;
                [__self refetchAnnotations:NO];
                [__self.tableView reloadData];
                [__self.mapRecenterButton setIsAnimating:NO];
            }
        }];
    }
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
