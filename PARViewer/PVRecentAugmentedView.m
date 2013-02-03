//
//  PVRecentAugmentedView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVRecentAugmentedView.h"
#import "PVImageCacheManager.h"
#import "PVTrendingSitesController.h"

@implementation PVRecentAugmentedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.augmentedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
        _augmentedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _augmentedImageView.clipsToBounds = YES;
        [_augmentedImageView.layer setBorderColor:[UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor];
        [_augmentedImageView.layer setBorderWidth:1.0];
        [self addSubview: _augmentedImageView];
    }
    return self;
}

- (void)setRecentlyAugmentedImageUrl:(NSString *)recentlyAugmentedImageUrl{
    // stop listening for image availability
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    _recentlyAugmentedImageUrl = recentlyAugmentedImageUrl;
    
    // set the poster image
    UIImage * img = [[PVImageCacheManager shared] imageForURL:[NSURL URLWithString:_recentlyAugmentedImageUrl]];
    if (!img) {
        img = [UIImage imageNamed: @"missing_image_78x78.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object:_recentlyAugmentedImageUrl];
    }
    [_augmentedImageView setImage: img];
}

- (void)siteImageReady:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL:[NSURL URLWithString:_recentlyAugmentedImageUrl]];
    [_augmentedImageView setImage: img];
}


@end
