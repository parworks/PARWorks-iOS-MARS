//
//  PVSiteDetailViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteDetailViewController.h"
#import "PVAugmentedPhotoViewController.h"
#import "ARSite+MARS_Extensions.h"
#import "UIImageView+AFNetworking.h"
#import "PVImageCacheManager.h"
#import "PVAppDelegate.h"
#import "GPUImagePicture.h"
#import "GPUImageGaussianBlurFilter.h"
#import "UINavigationItem+PVAdditions.h"
#import "UIColor+ThemeAdditions.h"
#import "PVCommentTableViewCell.h"
#import "UIFont+ThemeAdditions.h"
#import "PVMapViewController.h"
#import "UINavigationBar+Additions.h"
#import "GPUImageBrightnessFilter.h"
#import "MapAnnotation.h"
#import "PVBorderedImageCell.h"

#define PARALLAX_WINDOW_HEIGHT 165.0
#define PARALLAX_IMAGE_HEIGHT 300.0

static NSString *cellIdentifier = @"AugmentedViewCellIdentifier";

@implementation PVSiteDetailViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithSite:(ARSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;
        [site fetchComments];
    }
    return self;
}

- (void)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self update];
    
    // register to receive updates about the site in the future
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_UPDATED object: self.site];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_COMMENTS_UPDATED object: self.site];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFacebookNotification:) name:NOTIF_FACEBOOK_LOGGED_IN object: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationItem];
    [self setupParallaxView];
}

- (void)setupParallaxView
{
    [_headerImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, PARALLAX_IMAGE_HEIGHT)];
    [_headerImageView setOverlayImageViewContentMode: UIViewContentModeScaleAspectFill];
    [_headerImageView setShowOutlineViewsOnly:YES];
    [_headerImageView setAnimateOutlineViewDrawing: NO];
    [self updateHeaderImageView: nil];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self setupTableFooterView];
    [self setupTableHeaderView];
    
    self.parallaxView = [[PVParallaxTableView alloc] initWithBackgroundView:_headerImageView
                                                        foregroundTableView:_tableView
                                                               windowHeight:PARALLAX_WINDOW_HEIGHT];
    _parallaxView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].applicationFrame.size.height - self.navigationController.navigationBar.frame.size.height);
    _parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _parallaxView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    [_parallaxView setTableHeaderView:_tableHeaderView headerExpansionEnabled:NO];
    [_parallaxView setLocalDelegate:self];
    [self.view addSubview:_parallaxView];
}

- (void)setupTableFooterView {
    [_addCommentButton.layer setBorderWidth:1.0];
    [_addCommentButton.layer setBorderColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor];
}

- (void)setupTableHeaderView
{
    CGFloat headerHeight = 0.0;
    
    if(_site.location.latitude == 0.0 && _site.location.latitude == 0.0)
        headerHeight = 55.0;
    else
        headerHeight = 165.0;
    
    CGSize siteDescriptionSize = [_site.siteDescription sizeWithFont:_descriptionTextView.font
                                                   constrainedToSize:CGSizeMake(_descriptionTextView.frame.size.width - 16.0, MAXFLOAT)
                                                       lineBreakMode:NSLineBreakByWordWrapping];
    [_descriptionTextView setFrame:CGRectMake(_descriptionTextView.frame.origin.x, _descriptionTextView.frame.origin.y, _descriptionTextView.frame.size.width,  MAX(siteDescriptionSize.height + 8.0, 29.0))];
    headerHeight = headerHeight + _descriptionTextView.frame.size.height;
    
    [_detailsMapView setFrame:CGRectMake(0.0, 0.0, _tableHeaderView.frame.size.width, headerHeight)];

    
    if(_site.totalAugmentedImages > 0){
        [_detailsPhotoScrollView setFrame:CGRectMake(0.0, _detailsMapView.frame.origin.y + _detailsMapView.frame.size.height, _tableHeaderView.frame.size.width, 132.0)];
        headerHeight = _detailsPhotoScrollView.frame.origin.y + _detailsPhotoScrollView.frame.size.height;
    }
    
    [_tableHeaderView setFrame:CGRectMake(_tableHeaderView.frame.origin.x, _tableHeaderView.frame.origin.y, _tableHeaderView.frame.size.width, headerHeight)];
    
    [self setupMapView];
    [self setupPhotoScrollView];
}

- (void)setupNavigationItem
{
    [self.navigationController.navigationBar addShadowEffect];
    
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

- (void)setupMapView{
    _identifierLabel.text = ([_site.identifier length] > 0) ? _site.identifier :  @"No identifier available";
    _addressLabel.text = ([_site.address length] > 0) ? _site.address : @"No address available";   
    _descriptionTextView.text = ([_site.siteDescription length] > 0) ? _site.siteDescription : @"No description available";
    
    if(_site.location.latitude == 0.0 && _site.location.latitude == 0.0){
        [_mapView setHidden:YES];
        [_mapShadowButton setHidden:YES];
    } else {
        [_mapView setHidden:NO];
        [_mapShadowButton setHidden:NO];
        MKCoordinateRegion region;
        region.center = _site.location;
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        [_mapView setRegion:region];
        
        MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:_site.location andTitle:_identifierLabel.text andSubtitle:_addressLabel.text];
        [_mapView addAnnotation:annotation];
    }

}

- (void)setupPhotoScrollView{
    [_collectionView registerClass:[PVBorderedImageCell class] forCellWithReuseIdentifier:cellIdentifier];
    [_collectionView.layer setBorderColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor];
    [_collectionView.layer setBorderWidth:1.0];
    
    _photoCountLabel.text = [NSString stringWithFormat:@"%ld Augmented Photo%@", _site.totalAugmentedImages, _site.totalAugmentedImages == 1 ? @"" : @"s"];
    
    [_collectionView reloadData];
}

- (void)takePhoto:(id)sender
{
    PVAugmentedPhotoViewController * p = [[PVAugmentedPhotoViewController alloc] init];
    [p setSite: _site];
    [self presentViewController:p animated:YES completion:nil];
}

- (void)updateHeaderImageView:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    NSDictionary * overlays = _site.posterImageOverlayJSON;
    if (!img) {
        img = [UIImage imageNamed: @"missing_image_300x150"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeaderImageView) name:NOTIF_IMAGE_READY object:[_site posterImageURL]];
        overlays = nil;
    }
    
    float scale = img.size.width / _site.originalImageWidth;
    ARAugmentedPhoto *photo = [[ARAugmentedPhoto alloc] initWithScaledImage: img atScale: scale andOverlayJSON: overlays];
    [_headerImageView setAugmentedPhoto: photo];
}

- (void)update
{
    [_tableView reloadData];
}

- (IBAction)addCommentButtonPressed:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"FBId"])
        [self showAddCommentViewController];
    else{
        PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate authorizeFacebook:YES];
    }
}

- (void)showAddCommentViewController{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if(_bgCopyImageView == nil){
        
        CGSize halfSize = CGSizeMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        UIGraphicsBeginImageContext(halfSize);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 0.5,0.5);
        [delegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _bgCopyImageView = [[GPUImageView alloc] initWithFrame: self.view.bounds];
        _bgCopyImageView.alpha = 0.0;
        [_bgCopyImageView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
        
        GPUImagePicture *_bgCopyPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput: NO];
        GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        [blurFilter setBlurSize: 1.1];
        [_bgCopyPicture addTarget: blurFilter];
        [blurFilter addTarget: _bgCopyImageView];

        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        [brightnessFilter setBrightness: -0.4];
        [_bgCopyPicture addTarget: brightnessFilter];
        [brightnessFilter addTarget: _bgCopyImageView];
        
        [_bgCopyPicture processImage];
        [_bgCopyPicture removeAllTargets];
        
        [delegate.window addSubview:_bgCopyImageView];
    }
    
    [UIView transitionWithView:self.view duration:1 options:UIViewAnimationOptionTransitionNone animations:^{
        _bgCopyImageView.alpha = 1.0;
    } completion:^(BOOL finished){
    }];

    if(!_addCommentViewController){
        _addCommentViewController = [[PVAddCommentViewController alloc] initWithNibName:@"PVAddCommentViewController" bundle:nil];
        _addCommentViewController.delegate = self;
        _addCommentViewController.site = _site;
    }
    
    [delegate.window addSubview:_addCommentViewController.view];
    [_addCommentViewController viewWillAppear:NO];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section {
    return [_site.comments count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Comments";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 35.0)];
    [view setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 300.0, 35.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
    [label setFont:[UIFont parworksFontWithSize:12.0]];
    label.text = sectionTitle;
    [label sizeToFit];
    [label setFrame:CGRectMake(label.frame.origin.x, 15.0, label.frame.size.width, label.frame.size.height)];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];
    
    PVCommentTableViewCell *cell = [tableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PVCommentTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    cell.comment = comment;
    [cell setIsFirstRow: ([indexPath row] == 0)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];
    NSLog(@"%@", [comment description]);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];
    
    CGSize size = [comment.body sizeWithFont:[UIFont parworksFontWithSize:15.0]
                           constrainedToSize:CGSizeMake(247.0, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat contentHeight = MAX(size.height, 20.0);
    CGFloat newHeight = contentHeight + 54.0;
    return MAX(newHeight, 74.0);
}



#pragma mark -
#pragma mark PSUICollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_site recentlyAugmentedImageCount];
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVBorderedImageCell *cell = (PVBorderedImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setUrl: [_site URLForRecentlyAugmentedImageAtIndex: [indexPath row]]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self photoAtIndexTapped: [indexPath row]];
}

- (void)photoAtIndexTapped:(int)index
{
    NSURL * url = [_site URLForRecentlyAugmentedImageAtIndex: index];
    UIImage * img = [[PVImageCacheManager shared] imageForURL: url];
    NSDictionary * json = [_site overlayJSONForRecentlyAugmentedImageAtIndex: index];
    
    float scale = img.size.width / _site.originalImageWidth;
    ARAugmentedPhoto * photo = [[ARAugmentedPhoto alloc] initWithScaledImage:img atScale: scale andOverlayJSON: json];
    PVAugmentedPhotoViewController * c = [[PVAugmentedPhotoViewController alloc] init];
    [c setAugmentedPhoto: photo];
    [c setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
    [self presentViewController:c animated:YES completion:NULL];
}


#pragma mark
#pragma mark PVAddCommentViewControllerDelegate methods

- (void)postedCommentSuccessfully:(PVAddCommentViewController *)vc{
    [self hideAddComment:vc];
    [_tableView reloadData];
}

- (void)cancelButtonPressed:(PVAddCommentViewController *)vc{
    [self hideAddComment:vc];
}

- (void)hideAddComment:(PVAddCommentViewController*)vc{
    if(vc!=nil){
        if(_bgCopyImageView != nil){
            [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
                _bgCopyImageView.alpha = 0.0;
            } completion:^(BOOL finished){
                [_bgCopyImageView removeFromSuperview];
                _bgCopyImageView = nil;
            }];
        }
        
        if(_addCommentViewController != nil){
            _addCommentViewController = nil;
        }
    }
}

- (IBAction)mapViewPressed:(id)sender{
    [self.navigationController pushViewController:[[PVMapViewController alloc] initWithSite:_site] animated:YES];
}

- (void)receivedFacebookNotification:(NSNotification *)notification {
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_INFO_REQUEST]){
        
    }
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_LOGGED_IN] && [[notification object] isEqualToString:@"YES"]){
        [self showAddCommentViewController];
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
        }
        
        return annotationView;
    }
}

@end
