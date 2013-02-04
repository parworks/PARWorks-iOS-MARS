//
//  PVSiteCardView.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "ARSite.h"
#import "ObjectiveChipmunk.h"

@class PVCardShingleView;

@interface PVSiteCardView : PSUICollectionViewCell
{
    ARSite * _site;
}

@property (nonatomic, strong) UIView *posterContainer;
@property (nonatomic, strong) UIImageView * posterImageView;
@property (nonatomic, strong) PVCardShingleView *shingleView;

- (void)setSite:(ARSite*)site;
- (void)setShingleOffset:(CGPoint)offset andRotation:(float)rotation;

@end


@interface PVCardShingleView : UIView

@property(nonatomic, strong) UIImageView *logoView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *augmentationLabel;
@property(nonatomic, strong) ARSite *site;

@end