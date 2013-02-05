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

#define PARALLAX_WINDOW_HEIGHT 165.0
#define PARALLAX_IMAGE_HEIGHT 300.0

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
    // Do any additional setup after loading the view from its nib.
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PARALLAX_IMAGE_HEIGHT)];
    _mapView.contentMode = UIViewContentModeScaleAspectFill;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self setupTableHeaderView];
    
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
    
    
    [[ARManager shared] findNearbySites:1.0 withCompletionBlock:^(NSArray* sites){
        self.nearbySites = sites;
        [self refetchAnnotations];
        [_tableView reloadData];
    }];
}

- (void)setupTableHeaderView{
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
    [_tableHeaderView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];
    [_tableHeaderView setFrame:CGRectMake(_tableHeaderView.frame.origin.x, _tableHeaderView.frame.origin.y, _tableHeaderView.frame.size.width, 0.0)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_nearbySites count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] >= [_nearbySites count]){
        UITableViewCell *c = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        if (!c){
            c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCell"];
            [c setBackgroundColor: [UIColor colorWithWhite:0.88 alpha:1]];
            [c setSelectionStyle: UITableViewCellSelectionStyleNone];
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
    if([indexPath row] < [_nearbySites count]){
        ARSite * site = [_nearbySites objectAtIndex: [indexPath row]];
        PVSiteDetailViewController * siteDetailController = [[PVSiteDetailViewController alloc] initWithSite: site];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:siteDetailController] animated:YES completion:NULL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220.0;
}

- (void)closeMap{
    [_parallaxView windowButtonPressed];
}

#pragma mark
#pragma mark PVParallaxTableViewDelegate methods

- (void)windowButtonPressed:(BOOL)isExpanded{
    if(isExpanded){
        self.navigationItem.rightBarButtonItem = nil;
    }
    else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeMap)];
    }
    [_mapView setRegion:region animated:YES];
}

- (void)refetchAnnotations{
    NSMutableArray *toRemove = [NSMutableArray array];
    for (id annotation in _mapView.annotations){
        if (annotation != _mapView.userLocation)
            [toRemove addObject:annotation];
    }
    [_mapView removeAnnotations:toRemove];   
    
    [self loadAnnotationsFromStorage];
}

- (void)loadAnnotationsFromStorage {
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
        
        double prevLat = 0.0;
        double prevLon = 0.0;
        
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
                
                MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:site.location andTitle:site.identifier andSubtitle:site.address];
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
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationReuseIdentifier];
        if(annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationReuseIdentifier];
        }
        
        return annotationView;
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
