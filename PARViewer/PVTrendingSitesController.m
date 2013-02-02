//
//  PVFirstViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVTrendingSitesController.h"
#import "PVSiteDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"
#import "ARSite.h"

static NSString *cellIdentifier = @"TestCell";


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
    
    [_backgroundView setFloatingPointIndex: 0];
    [_collectionView registerClass: [PVSiteCardView class] forCellWithReuseIdentifier: cellIdentifier];
    [_collectionView setShowsHorizontalScrollIndicator: NO];
    [_collectionView setPagingEnabled: YES];
    [_backgroundView setDelegate: self];
}

- (void)trendingSitesUpdated:(NSNotification*)notif
{
    // trigger update of our views
    [_collectionView reloadData];
    [_pageControl setNumberOfPages: [[[ARManager shared] trendingSites] count]];
}

- (NSURL*)urlForSiteAtIndex:(int)ii
{
    if (ii < 0)
        return nil;
    if (ii >= [[[ARManager shared] trendingSites] count])
        return nil;
    
    return [[[[ARManager shared] trendingSites] objectAtIndex: ii] posterImageURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark PSUICollectionView stuff

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[ARManager shared] trendingSites] count];
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVSiteCardView *cell = (PVSiteCardView *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ARSite * site = [[[ARManager shared] trendingSites] objectAtIndex: [indexPath row]];
    
    [cell setSite: site];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ARSite * site = [[[ARManager shared] trendingSites] objectAtIndex: [indexPath row]];
    PVSiteDetailViewController * detail = [[PVSiteDetailViewController alloc] initWithSite: site];
    [self presentViewController: detail animated:YES completion:NULL];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // determine visible index based on scroll offset
    int page = [[_collectionView indexPathForItemAtPoint: CGPointMake(scrollView.contentOffset.x + self.view.center.x, self.view.center.y)] row];
    [_pageControl setCurrentPage: page];
    
    // adjust the background parallax view
    [_backgroundView setFloatingPointIndex: scrollView.contentOffset.x / scrollView.frame.size.width];
}

@end
