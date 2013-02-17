//
//  PVIntroCard.h
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

typedef enum {
    PVIntroCardStyle_1,
    PVIntroCardStyle_2,
    PVIntroCardStyle_3
} PVIntroCardStyle;

@interface PVIntroCard : PSUICollectionViewCell

@property(nonatomic, strong) UIView *outerCard;
@property(nonatomic, strong) UIView *innerCard;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *skipButton;
@property(nonatomic, assign) PVIntroCardStyle cardStyle;

@end
