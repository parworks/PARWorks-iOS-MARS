//
//  PVFirstViewController.m
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

#import "PVTrendingSitesController.h"
#import "PVSiteDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "ARLoadingView.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"
#import "ARSite.h"
#import "JSSlidingViewController.h"
#import "PVFlowLayout.h"
#import "UIViewAdditions.h"
#import "UAPush.h"
#import "PVIntroViewController.h"

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
    
    [self attachRightIntroButton];

	// make sure our cached data is up-to-date
	[[ARManager shared] fetchTrendingSites];
    [_loadingView startAnimating];
    
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
    [_backgroundView preloadBlurredImages];
    [_loadingView stopAnimating];
    
    PVFlowLayout * layout = (PVFlowLayout*)_collectionView.collectionViewLayout;
	CGFloat centerX = (_collectionView.contentOffset.x + _collectionView.contentInset.left) / ([layout itemSize].width + [layout minimumLineSpacing]);
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
	CGFloat centerX = (_collectionView.contentOffset.x + _collectionView.contentInset.left) / ([layout itemSize].width + [layout minimumLineSpacing]);

	[_pageControl setCurrentPage: roundf(centerX)];
	[_backgroundView setFloatingPointIndex:centerX];
}

- (void)viewDidUnload
{
    [self setLoadingView:nil];
    [super viewDidUnload];
}


@end
