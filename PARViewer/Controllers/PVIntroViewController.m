//
//  PVIntroViewController.m
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVAppDelegate.h"
#import "PVIntroCard.h"
#import "PVIntroViewController.h"
#import "UAPush.h"
#import "UIViewController+Transitions.h"
#import "UIView+ImageCapture.h"
#import "UIViewAdditions.h"


@implementation PVIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageControl.numberOfPages = 4;
    _collectionView.delaysContentTouches = NO;
}

- (void)dealloc
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [super viewWillAppear:animated];
    if ([self.presentedViewController isKindOfClass:[UIImagePickerController class]]) {
        [UIView animateWithDuration:1.0 delay:0.1 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.view.hidden = NO;
        } completion:nil];
    }
    
    [_collectionView registerClass:[PVIntroCard class] forCellWithReuseIdentifier:@"IntroCard"];
    BOOL isiPhone5 = [PVAppDelegate isiPhone5];
    if (isiPhone5) {
        [((PSUICollectionViewFlowLayout *)_collectionView.collectionViewLayout) setItemSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(augmentTestSite:) name:@"augmentButtonTapped" object:nil];
    _hintTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showHint) userInfo:nil repeats:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewWillDisappear:animated];
}

- (void)showHint
{
    PVIntroCard *card = (PVIntroCard *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    CGRect frame = card.swipeImageView.frame;

    card.swipeImageView.alpha = 0.0;
    [card.swipeImageView setFrameX:(card.swipeImageView.frame.origin.x + 20)];
    [UIView animateWithDuration:0.2 animations:^{
        card.swipeImageView.alpha = 1.0;
        card.swipeImageView.frame = frame;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)doneButtonTapped
{
    CGFloat scaleX = 57/self.view.bounds.size.width;
    CGFloat scaleY = 46/self.view.bounds.size.height;
    CGAffineTransform t = CGAffineTransformMakeScale(scaleX, scaleY);
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
        self.view.center = CGPointMake(self.view.bounds.size.width - (57/2.0), (46/2));
        self.view.transform = t;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:self.parentViewController];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        
        // Somewhere in the app, this will enable push, setting it to NO will disable push
        // This will trigger the proper registration or de-registration code in the library.
        [[UAPush shared] setPushEnabled:YES];
    }];
}

#pragma mark - PSUICollectionView methods
- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVIntroCard *cell = (PVIntroCard *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IntroCard" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.cardStyle = PVIntroCardStyle_1;
            break;
        case 1:
            cell.cardStyle = PVIntroCardStyle_2;
            break;
        case 2:
            cell.cardStyle = PVIntroCardStyle_3;
            break;
        case 3:
            cell.cardStyle = PVIntroCardStyle_4;
            [cell.skipButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// determine visible index based on scroll offset
    [_hintTimer invalidate];
	int page = [[_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + self.view.center.x, self.view.center.y)] row];
	[_pageControl setCurrentPage:page];    
}

#pragma mark Showing the Camera

- (void)augmentTestSite:(NSNotification*)notif
{
    NSString * siteIdentifier = (NSString*)[notif object];
    if (siteIdentifier == nil)
        return;
    
    _currentExampleSite = [[ARSite alloc] initWithIdentifier: siteIdentifier];
    
    UIImage * screenCap = [self.view imageRepresentationAtScale: 1.0];
    UIImage * depthImage = [UIImage imageNamed:@"unfold_depth_image.png"];
    self.view.hidden = YES;
    
    _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
    _cameraOverlayView.site = _currentExampleSite;
    
    UIImagePickerController *picker = [self imagePicker];
    picker.delegate = _cameraOverlayView;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        picker.cameraOverlayView = _cameraOverlayView;
        _cameraOverlayView.imagePicker = picker;
    }
    
    UIImage * background = nil;
    if (self.view.frame.size.height < 500)
        background = [UIImage imageNamed:@"camera_iris.png"];
    else
        background = [UIImage imageNamed:@"camera_iris_568h.png"];
    
    [self peelPresentViewController:picker withBackgroundImage:background andContentImage:screenCap depthImage:depthImage];
    
    // update the skip button to say "Done!"
    PVIntroCard * lastCard = (PVIntroCard*)[_collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem:3 inSection:0]];
    [[lastCard skipButton] setTitle:@"Done!" forState:UIControlStateNormal];
}


- (UIImagePickerController *)imagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.showsCameraControls = NO;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    return picker;
}


@end
