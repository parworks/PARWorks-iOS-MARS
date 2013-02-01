//
//  PVFirstViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PVTrendingBlurredBackgroundView.h"

@interface PVTrendingSitesController : UIViewController <PVTrendingBlurredBackgroundViewDelegate, PSUICollectionViewDataSource, PSUICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet PVTrendingBlurredBackgroundView *backgroundView;
@property (weak, nonatomic) IBOutlet PSUICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
