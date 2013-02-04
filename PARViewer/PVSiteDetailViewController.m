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

    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIImage imageNamed:@"posterImage.png"].size.height)];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerImageView.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0];
    
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    if (!img) {
        img = [UIImage imageNamed:@"posterImage.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object: [_site posterImageURL]];
    }
    [_headerImageView setImage: img];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 10.0, 320.0, 51.0)];
    [tableFooterView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 31.0)];
    [addCommentButton addTarget:self action:@selector(addCommentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addCommentButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    [addCommentButton setTitle:@"Leave a Comment" forState:UIControlStateNormal];
    [addCommentButton setTitleColor:[UIColor colorWithRed:50.0/255.0 green:98.0/255.0 blue:162.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [addCommentButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [addCommentButton.layer setBorderWidth:1.0];
    [addCommentButton.layer setBorderColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor];
    [addCommentButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [addCommentButton setImage:[UIImage imageNamed:@"leave_comment.png"] forState:UIControlStateNormal];
    [addCommentButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 15.0)];
    [addCommentButton setAdjustsImageWhenHighlighted:NO];
    [addCommentButton setShowsTouchWhenHighlighted:YES];
    [tableFooterView addSubview:addCommentButton];
    _tableView.tableFooterView = tableFooterView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
    [headerView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];
    
    self.detailsMapView = [[PVDetailsMapView alloc] initWithSite:_site];
    [_detailsMapView setFrame:CGRectMake(0.0, 0.0, headerView.frame.size.width, 165.0)];
    [headerView addSubview:_detailsMapView];
    
    self.detailsPhotoScrollView = [[PVDetailsPhotoScrollView alloc] initWithSite:_site];
    [_detailsPhotoScrollView setFrame:CGRectMake(0.0, _detailsMapView.frame.origin.y + _detailsMapView.frame.size.height, headerView.frame.size.width, 132.0)];
    [headerView addSubview:_detailsPhotoScrollView];
    
    [headerView setFrame:CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, _detailsPhotoScrollView.frame.origin.y + _detailsPhotoScrollView.frame.size.height)];
    
    self.parallaxView = [[PVParallaxTableView alloc] initWithBackgroundView:_headerImageView
                                                        foregroundTableView:_tableView];
    _parallaxView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].applicationFrame.size.height - self.navigationController.navigationBar.frame.size.height);
    _parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _parallaxView.backgroundHeight = 150.0f;
    //    _parallaxView.tableViewDelegate = self;
    _parallaxView.backgroundColor = [UIColor clearColor];
    [_parallaxView setTableHeaderView:headerView];
    [self.view addSubview:_parallaxView];
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

- (void)takePhoto:(id)sender
{
    PVAugmentedPhotoViewController * p = [[PVAugmentedPhotoViewController alloc] init];
    [p setSite: _site];
    [self presentViewController:p animated:YES completion:nil];
}

- (void)siteImageReady:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    [_headerImageView setImage: img];
}

- (void)update
{
    [_tableView reloadData];
}

- (void)addCommentButtonPressed
{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate authorizeFacebook:YES];
}

- (void)showAddCommentViewController{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if(_bgCopyImageView == nil){
        
        UIGraphicsBeginImageContext(self.view.frame.size);
        [delegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _bgCopyImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
        _bgCopyImageView.alpha = 0.0;
        [_bgCopyImageView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
        
        CGSize size = CGSizeMake(image.size.width / 2.5, image.size.height / 2.5);
        
        GPUImagePicture *_bgCopyPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
        GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        [blurFilter setBlurSize: 1.06];
        [blurFilter forceProcessingAtSize: size];
        [_bgCopyPicture addTarget: blurFilter];
        [blurFilter addTarget: _bgCopyImageView];
        [_bgCopyPicture processImage];
        
        [delegate.window addSubview:_bgCopyImageView];
    }
    
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _bgCopyImageView.alpha = 1.0;
    } completion:^(BOOL finished){
        if(!_addCommentViewController){
            _addCommentViewController = [[PVAddCommentViewController alloc] initWithNibName:@"PVAddCommentViewController" bundle:nil];
            _addCommentViewController.delegate = self;
            _addCommentViewController.site = _site;
        }
        
        [delegate.window addSubview:_addCommentViewController.view];
        [_addCommentViewController viewWillAppear:NO];
    }];
}

- (void)backButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [label setFont:[UIFont systemFontOfSize:12.0]];
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
    
    CGSize size = [comment.body sizeWithFont:[UIFont systemFontOfSize:15.0]
                           constrainedToSize:CGSizeMake(247.0, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat contentHeight = MAX(size.height, 20.0);
    CGFloat newHeight = contentHeight + 54.0;
    return MAX(newHeight, 74.0);
}


#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_parallaxView updateContentOffset];
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

- (void)receivedFacebookNotification:(NSNotification *)notification {
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_INFO_REQUEST]){
       
    }
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_LOGGED_IN] && [[notification object] isEqualToString:@"YES"]){
        [self showAddCommentViewController];
    }
}

@end
