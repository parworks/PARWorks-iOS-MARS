//
//  PVSiteCardView.h
//  PARViewer
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