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
#import "JSSlidingViewController.h"
#import "PVFlowLayout.h"
#import "UIViewAdditions.h"

static NSString * cellIdentifier = @"TestCell";

@implementation PVTrendingSitesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		self.title = NSLocalizedString(@"Trending", @"Trending");
		self.tabBarItem.image = [UIImage imageNamed:@"icon_trending"];
        
        _physicsContainer = [[SiteCardPhysicsContainer alloc] init];
        [_physicsContainer setup];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        _displayLink.frameInterval = 1;
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

	[_backgroundView setFloatingPointIndex:0];
	[_collectionView registerClass:[PVSiteCardView class] forCellWithReuseIdentifier:cellIdentifier];
	[_collectionView setShowsHorizontalScrollIndicator:NO];
	[_backgroundView setDelegate:self];
}

// Set up the display link to control the timing of the animation.
- (void)viewDidAppear:(BOOL)animated
{
    // reset so that things don't start swining where they left off when you left the view
    [_physicsContainer resetSign];

    // trigger update of our views
    [self resumeDisplayLink];
}

- (void)resumeDisplayLink
{
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self pauseDisplayLink];
}

- (void)pauseDisplayLink
{
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

// This method is called each frame to update the scene.
// It is called from the display link every time the screen wants to redraw itself.
- (void)update
{
	// Step (simulate) the space based on the time since the last update.
	cpFloat dt = _displayLink.duration * _displayLink.frameInterval;

	// Update the position of the card and then advance our simulation
    [_physicsContainer setCardX: fmaxf(0, (_collectionView.contentOffset.x) / 2)];
    [_physicsContainer step: dt * 1.75];

	// Update any cards onscreen.
	NSArray * cards = [self.collectionView visibleCells];
	for (PVSiteCardView * view in cards)
		if ([view isKindOfClass:[PVSiteCardView class]])
            [view setShingleOffset: _physicsContainer.signOffset andRotation: _physicsContainer.signRotation];
}

- (void)trendingSitesUpdated:(NSNotification *)notif
{
	// trigger update of our views
	[_collectionView reloadData];
    PVFlowLayout * layout = (PVFlowLayout*)_collectionView.collectionViewLayout;
	CGFloat centerX = _collectionView.contentOffset.x / ([layout itemSize].width + [layout minimumLineSpacing]);
    [_backgroundView setFloatingPointIndex: centerX];
	[_pageControl setNumberOfPages:[[[ARManager shared] trendingSites] count]];
}

- (NSURL *)urlForSiteAtIndex:(int)ii
{
	if (ii < 0)
		return nil;

	if (ii >= [[[ARManager shared] trendingSites] count])
		return nil;

    return [[[[ARManager shared] trendingSites] objectAtIndex:ii] posterImageURL];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
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
	PVSiteCardView * cell = (PVSiteCardView *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	ARSite * site = [[[ARManager shared] trendingSites] objectAtIndex:[indexPath row]];

	[cell setSite:site];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ARSite * site = [[[ARManager shared] trendingSites] objectAtIndex:[indexPath row]];

    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:[[PVSiteDetailViewController alloc] initWithSite:site]];
    [self presentViewController:navController animated:YES completion:NULL];
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    PVFlowLayout * layout = (PVFlowLayout*)_collectionView.collectionViewLayout;
	CGFloat centerX = scrollView.contentOffset.x / ([layout itemSize].width + [layout minimumLineSpacing]);

	// determine visible index based on scroll offset
	int page = [[_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + self.view.center.x, self.view.center.y)] row];
	[_pageControl setCurrentPage:page];

	// adjust the background parallax view
	[_backgroundView setFloatingPointIndex:centerX];
}

@end
