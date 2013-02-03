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
{
    BOOL _firstLoad;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstLoad = YES;
        self.title = NSLocalizedString(@"Trending", @"Trending");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_trending"];
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

- (void)viewWillAppear:(BOOL)animated
{
    if (_firstLoad) {
        // Set up our chipmunk simulation
        _space = [[ChipmunkSpace alloc] init];
        [_space setGravity:cpv(0, -750)];
        [_space setDamping:0.3];
        [_space addBounds:self.view.bounds thickness:5 elasticity:1 friction:1 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:nil];
       
        cpFloat mass = 100.0;
        cpFloat posterWidth = 250.0;
        cpFloat posterHeight = 245.0;
        cpFloat shingleWidth = 205.0;
        cpFloat shingleHeight = 70.0;
        cpFloat ropeLength = 50;
        cpFloat ropeOverlap = 10;
        cpFloat marginY = (self.view.bounds.size.height - 310)/2;
        
        _posterBody = [[ChipmunkBody alloc] initWithMass:mass andMoment:INFINITY];
        _posterBody.pos = cpv(self.view.bounds.size.width/2, (marginY + (posterHeight/2) + ropeLength + shingleHeight));
        [_space add:_posterBody];
        
        _posterShape = [[ChipmunkPolyShape alloc] initBoxWithBody:_posterBody width:posterWidth height:posterHeight];
        _posterShape.friction = 1.0;
        _posterShape.elasticity = 0.5;
        [_space add:_posterShape];
        
        [_space add:[ChipmunkGrooveJoint grooveJointWithBodyA:_space.staticBody bodyB:_posterBody groove_a:cpv(0, _posterBody.pos.y) groove_b:cpv(1460, _posterBody.pos.y) anchr2:cpvzero]];
        
        _shingleBody = [[ChipmunkBody alloc] initWithMass:1 andMoment:cpMomentForBox(1, shingleWidth, shingleHeight)];
        _shingleBody.pos = cpv(_posterBody.pos.x, marginY + shingleHeight/2);
        [_space add:_shingleBody];
        
        _shingleShape = [[ChipmunkPolyShape alloc] initBoxWithBody:_shingleBody width:shingleWidth height:shingleHeight];
        _shingleShape.friction = 1.0;
        _shingleShape.elasticity = 0.5;
        [_space add:_shingleShape];

        
        //(-posterHeight + ropeLength)/2)
        //(shingleHeight + ropeLength)/2)
        ChipmunkSlideJoint *joint1 = [[ChipmunkSlideJoint alloc] initWithBodyA:_posterBody
                                                                         bodyB:_shingleBody
                                                                        anchr1:cpv(-137,  -(posterHeight)/2)
                                                                        anchr2:cpv(-137,  (shingleHeight)/2)
                                                                           min:ropeLength
                                                                           max:ropeLength + 10];
        [_space add:joint1];
        
        ChipmunkSlideJoint *joint2 = [[ChipmunkSlideJoint alloc] initWithBodyA:_posterBody
                                                                         bodyB:_shingleBody
                                                                        anchr1:cpv(137, (-posterHeight)/2)
                                                                        anchr2:cpv(137, (shingleHeight)/2)
                                                                           min:ropeLength
                                                                           max:ropeLength + 10];
        [_space add:joint2];
        
        _firstLoad = NO;
    }
}

// Set up the display link to control the timing of the animation.
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	_displayLink.frameInterval = 1;
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

// This method is called each frame to update the scene.
// It is called from the display link every time the screen wants to redraw itself.
- (void)update
{
	// Step (simulate) the space based on the time since the last update.
	cpFloat dt = _displayLink.duration*_displayLink.frameInterval;
	[_space step:dt];
	
	// Update any cards onscreen.
    NSArray *cards = [self.collectionView visibleCells];
    for (PVSiteCardView *view in cards) {
        if ([view isKindOfClass:[PVSiteCardView class]]) {
            [view.shingleView updatePositionWithBody:_shingleBody];
        }
    }

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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[PVSiteDetailViewController alloc] initWithSite: site]] animated:YES completion:NULL];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat centerX = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    // Move our physics card
    _posterBody.pos = cpv(centerX, _posterBody.pos.y);
    
    // determine visible index based on scroll offset
    int page = [[_collectionView indexPathForItemAtPoint: CGPointMake(scrollView.contentOffset.x + self.view.center.x, self.view.center.y)] row];
    [_pageControl setCurrentPage: page];
    
    // adjust the background parallax view
    [_backgroundView setFloatingPointIndex: centerX];
}

@end
