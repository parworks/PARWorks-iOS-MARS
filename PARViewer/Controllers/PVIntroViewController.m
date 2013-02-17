//
//  PVIntroViewController.m
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVIntroCard.h"
#import "PVIntroViewController.h"

@interface PVIntroViewController ()

@end

@implementation PVIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_collectionView registerClass:[PVIntroCard class] forCellWithReuseIdentifier:@"IntroCard"];    
    _pageControl.numberOfPages = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    _pageControl.frame = CGRectMake(_pageControl.frame.origin.x, self.view.bounds.size.height - 30, _pageControl.frame.size.width, _pageControl.frame.size.height);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonTapped
{
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:self.parentViewController];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}


#pragma mark - PSUICollectionView methods
- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVIntroCard *cell = (PVIntroCard *)[collectionView dequeueReusableCellWithReuseIdentifier:@"IntroCard" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            // TODO: Set image asset
            cell.cardStyle = PVIntroCardStyle_1;
            break;
        case 1:
            // TODO: Set image asset
            cell.cardStyle = PVIntroCardStyle_2;
            break;
        case 2:
            // TODO: Set image asset
            cell.cardStyle = PVIntroCardStyle_3;
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
	int page = [[_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + self.view.center.x, self.view.center.y)] row];
	[_pageControl setCurrentPage:page];    
}


@end
