//
//  PVDetailsPhotoScrollView.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVDetailsPhotoScrollView.h"
#import "ARSite+MARS_Extensions.h"
#import "PVRecentAugmentedView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+ThemeAdditions.h"

static NSString *cellIdentifier = @"AugmentedViewCellIdentifier";

@implementation PVDetailsPhotoScrollView

- (void)initialize{
    [self setBackgroundColor:[UIColor clearColor]];
              
    self.photoCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_photoCountLabel setBackgroundColor:[UIColor clearColor]];
    [_photoCountLabel setUserInteractionEnabled:NO];
    [_photoCountLabel setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
    [_photoCountLabel setFont:[UIFont parworksFontWithSize:12.0]];
    [self addSubview:_photoCountLabel];
    
    PSUICollectionViewFlowLayout *aFlowLayout = [[PSUICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(78, 78)];
    [aFlowLayout setMinimumInteritemSpacing:7.0];
    [aFlowLayout setMinimumLineSpacing:7.0];
    [aFlowLayout setSectionInset: UIEdgeInsetsMake(0, 7, 0, 7)];

    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView = [[PSUICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:aFlowLayout];
    [_collectionView registerClass:[PVRecentAugmentedView class] forCellWithReuseIdentifier:cellIdentifier];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [_collectionView setShowsHorizontalScrollIndicator:YES];
    [_collectionView.layer setBorderColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0].CGColor];
    [_collectionView.layer setBorderWidth:1.0];
    [self addSubview:_collectionView];
}

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
        [self setFrame:rect];
    }
    return self;
}

- (id)initWithSite:(ARSite*)site{
    if(self = [self initWithFrame:CGRectZero]){
        self.site = site;
        
        _photoCountLabel.text = [NSString stringWithFormat:@"%ld Augmented Photo%@", _site.totalAugmentedImages, _site.totalAugmentedImages == 1 ? @"" : @"s"];
        
        [_collectionView reloadData];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_photoCountLabel setFrame:CGRectMake(10.0, 10.0, frame.size.width - 20.0, 20.0)];
    [_collectionView setFrame:CGRectMake(10.0, _photoCountLabel.frame.origin.y + _photoCountLabel.frame.size.height, frame.size.width - 20.0, 95.0)];
}


#pragma mark -
#pragma mark PSUICollectionView stuff

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_site recentlyAugmentedImages] count];
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVRecentAugmentedView *cell = (PVRecentAugmentedView *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary * imageAttributes = [[_site recentlyAugmentedImages] objectAtIndex:[indexPath row]];
    [cell setAugmentedImageAttributes: imageAttributes];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{        
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


@end
