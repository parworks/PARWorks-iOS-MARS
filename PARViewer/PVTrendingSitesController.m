//
//  PVFirstViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVTrendingSitesController.h"
#import "ASIHTTPRequest.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"

@interface PVTrendingSitesController ()

@end

@implementation PVTrendingSitesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trending", @"Trending");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_trending"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // subscribe to receive updates about the trending sites list
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trendingSitesUpdated:) name:NOTIF_TRENDING_SITES_UPDATED object:nil];

    // make sure our cached data is up-to-date
    [[ARManager shared] fetchTrendingSites];
}

- (void)trendingSitesUpdated:(NSNotification*)notif
{
    // trigger update of our views
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
