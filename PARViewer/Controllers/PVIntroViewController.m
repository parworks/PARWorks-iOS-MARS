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
    _pageControl.numberOfPages = 4;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_collectionView registerClass:[PVIntroCard class] forCellWithReuseIdentifier:@"IntroCard"];
    BOOL isiPhone5 = [PVAppDelegate isiPhone5];
    if (isiPhone5) {
        [((PSUICollectionViewFlowLayout *)_collectionView.collectionViewLayout) setItemSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    _hintTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showHint) userInfo:nil repeats:NO];
}

- (void)showHint
{
    PVIntroCard *card = (PVIntroCard *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    card.swipeImageView.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        card.swipeImageView.alpha = 1.0;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)doneButtonTapped
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
        self.view.transform = CGAffineTransformMakeScale(2, 2);
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


@end
