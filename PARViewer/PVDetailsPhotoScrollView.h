//
//  PVDetailsPhotoScrollView.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSite.h"
#import "PSTCollectionView.h"

@interface PVDetailsPhotoScrollView : UIView<PSUICollectionViewDataSource, PSUICollectionViewDelegate>

@property (nonatomic, strong) ARSite *site;
@property (nonatomic, strong) UILabel *photoCountLabel;
@property (nonatomic, strong) PSUICollectionView *collectionView;

- (id) initWithSite:(ARSite*)site;

@end
