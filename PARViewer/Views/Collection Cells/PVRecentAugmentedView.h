//
//  PVRecentAugmentedView.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PSTCollectionView.h"

@interface PVRecentAugmentedView : PSUICollectionViewCell

@property (nonatomic, strong) NSDictionary * augmentedImageAttributes;
@property (nonatomic, strong) UIImageView * imageView;

@end
