//
//  PVSiteDetailViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteDetailViewController.h"
#import "ARSite+MARS_Extensions.h"
#import "UIImageView+AFNetworking.h"
#import "PVImageCacheManager.h"
#import "PVAppDelegate.h"
#import "GPUImagePicture.h"
#import "GPUImageGaussianBlurFilter.h"

@interface PVSiteDetailViewController ()

@end

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    
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
//    _tableView.delegate = self;
    
    UIButton *addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [addCommentButton addTarget:self action:@selector(addCommentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [addCommentButton setTitle:@"Add Comment" forState:UIControlStateNormal];
    _tableView.tableFooterView = addCommentButton;
    
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
    _parallaxView.tableViewDelegate = self;
    _parallaxView.backgroundColor = [UIColor greenColor];
    [_parallaxView setTableHeaderView:headerView];
    [self.view addSubview:_parallaxView];
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

- (void)addCommentButtonPressed{ 
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
    [view setBackgroundColor:[UIColor clearColor]];
    
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
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    cell.textLabel.text = comment.body;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];
    NSLog(@"%@", [comment description]);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 44.0;
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


@end
