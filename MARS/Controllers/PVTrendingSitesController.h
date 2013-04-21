//
//  PVFirstViewController.h
//  MARS
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

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "PVTrendingBlurredBackgroundView.h"
#import "PVBaseViewController.h"
#import "PVSiteCardView.h"
#import "SiteCardPhysicsContainer.h"
#import "ARLoadingView.h"

@interface PVTrendingSitesController : PVBaseViewController <PVTrendingBlurredBackgroundViewDelegate, PSUICollectionViewDataSource, PSUICollectionViewDelegate>
{
    CADisplayLink * _displayLink;
    SiteCardPhysicsContainer * _physicsContainer;
}

@property (weak, nonatomic) IBOutlet PVTrendingBlurredBackgroundView *backgroundView;
@property (weak, nonatomic) IBOutlet PSUICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet ARLoadingView *loadingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)viewDidLoad;

- (void)trendingSitesUpdated:(NSNotification*)notif;
- (NSURL*)urlForSiteAtIndex:(int)ii;
- (void)didReceiveMemoryWarning;


@end
