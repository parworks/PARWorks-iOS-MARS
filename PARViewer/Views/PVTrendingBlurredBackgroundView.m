//
//  PVTrendingBlurredBackgroundView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVImageCacheManager.h"
#import "PVTrendingBlurredBackgroundView.h"

@implementation PVTrendingBlurredBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self populateImageViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGPUImages) name:NOTIF_IMAGE_READY object: nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [self populateImageViews];
}

- (void)populateImageViews
{
    _imageViewRect = self.bounds;
    _imageViewRect.origin.x -= 50;
    _imageViewRect.size.width += 100;
    
    _baseImageView = [[UIImageView alloc] initWithFrame: _imageViewRect];
    [_baseImageView setContentMode: UIViewContentModeScaleAspectFill];
    [self addSubview: _baseImageView];
    
    _nextImageView = [[UIImageView alloc] initWithFrame: _imageViewRect];
    [_nextImageView setContentMode: UIViewContentModeScaleAspectFill];
    [self addSubview: _nextImageView];
}

- (void)setFloatingPointIndex:(float)index
{
    _floatingPointIndex = index;
    // which three views should we be showing?
    float newBaseIndex = MAX(0, floorf(index));
    float newNextIndex = newBaseIndex + 1;

    if (newNextIndex != _nextIndex)
        _nextImageView.image = nil;

    if (newBaseIndex != _baseIndex)
        _baseImageView.image = nil;
    
    _baseIndex = newBaseIndex;
    _nextIndex = newNextIndex;
    
    float fraction = sinf((index - _baseIndex) * M_PI / 2);
    [self refreshGPUImages];
    
    [_baseImageView setAlpha: 1];
    [_baseImageView setTransform: CGAffineTransformMakeTranslation(-fraction * 40, 0)];
    [_nextImageView setAlpha: fraction];
    [_nextImageView setTransform: CGAffineTransformMakeTranslation((1-fraction) * 40, 0)];
}

- (void)refreshGPUImages
{
    if ((_baseImageView.image != nil) && (_nextImageView.image != nil))
        return;

    // get images
    NSURL * baseURL = [_delegate urlForSiteAtIndex: _baseIndex];
    UIImage * baseImage = [[PVImageCacheManager shared] imageForURL: baseURL];
    NSURL * nextURL = [_delegate urlForSiteAtIndex: _nextIndex];
    UIImage * nextImage = [[PVImageCacheManager shared] imageForURL: nextURL];
    
    if ((_baseImageView.image == nil) && (baseImage))
        [_baseImageView setImage: [[PVImageCacheManager shared] blurredImageForURL: baseURL]];
    
    if ((_nextImageView.image == nil) && (nextImage)) {
        [_nextImageView setImage: [[PVImageCacheManager shared] blurredImageForURL: nextURL]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end
