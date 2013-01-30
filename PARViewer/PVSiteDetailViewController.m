//
//  PVSiteDetailViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteDetailViewController.h"
#import "ARSite+MARS_Extensions.h"

@interface PVSiteDetailViewController ()

@end

@implementation PVSiteDetailViewController

- (id)initWithSite:(ARSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        
        // start refreshing the site comments
        [site fetchComments];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self update];
    
    // register to receive updates about the site in the future
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_UPDATED object: self.site];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_COMMENTS_UPDATED object: self.site];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    
}
@end
