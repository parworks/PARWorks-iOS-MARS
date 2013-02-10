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
#import "ARAugmentedView.h"

@class PVCardShingleView;
@class PVCardRopeView;

@protocol PVCardRopeViewDelegate <NSObject>
@required
- (CGPoint)leftRopePoint;
- (CGPoint)rightRopePoint;

@end

@interface PVSiteCardView : PSUICollectionViewCell <PVCardRopeViewDelegate>
{
    ARSite * _site;
}

@property (nonatomic, strong) UIView *posterContainer;
@property (nonatomic, strong) ARAugmentedView * posterImageView;
@property (nonatomic, strong) PVCardShingleView *shingleView;
@property (nonatomic, strong) PVCardRopeView *ropeView;

@property(nonatomic, assign) CGPoint leftRopePoint;
@property(nonatomic, assign) CGPoint rightRopePoint;

- (void)setSite:(ARSite*)site;
- (void)setShingleOffset:(CGPoint)offset andRotation:(float)rotation;

@end



@interface PVCardShingleView : UIView <PVCardRopeViewDelegate>

@property(nonatomic, strong) UIImageView *logoView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *augmentationLabel;
@property(nonatomic, strong) ARSite *site;

@property(nonatomic, assign) CGPoint leftRopePoint;
@property(nonatomic, assign) CGPoint rightRopePoint;

@end



@interface PVCardRopeView : UIView

@property(nonatomic, weak) UIView<PVCardRopeViewDelegate> *posterView;
@property(nonatomic, weak) UIView<PVCardRopeViewDelegate> *shingleView;

- (id)initWithFrame:(CGRect)frame;
                                                                                
@end