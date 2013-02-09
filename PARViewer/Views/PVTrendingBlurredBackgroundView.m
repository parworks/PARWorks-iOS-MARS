//
//  PVTrendingBlurredBackgroundView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVTrendingBlurredBackgroundView.h"
#import "PVImageCacheManager.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageBrightnessFilter.h"

@implementation PVTrendingBlurredBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self populateImageViews];
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
    
    _baseImageView = [[GPUImageView alloc] initWithFrame: _imageViewRect];
    [_baseImageView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
    [self addSubview: _baseImageView];
    
    _nextImageView = [[GPUImageView alloc] initWithFrame: _imageViewRect];
    [_nextImageView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
    [self addSubview: _nextImageView];
}

- (void)setFloatingPointIndex:(float)index
{
    _floatingPointIndex = index;
    // which three views should we be showing?
    float newBaseIndex = MAX(0, floorf(index));
    float newNextIndex = newBaseIndex + 1;
    
    if (newBaseIndex == _nextIndex) {
        _basePicture = _nextPicture;
        _baseIndex = newBaseIndex;
        [self swapImageViews];
    }
    if (newNextIndex == _baseIndex) {
        _nextPicture = _basePicture;
        _nextIndex = newNextIndex;
        [self swapImageViews];
    }
    if (newNextIndex != _nextIndex)
        _nextPicture = nil;

    if (newBaseIndex != _baseIndex)
        _basePicture = nil;
    
    
    _baseIndex = newBaseIndex;
    _nextIndex = newNextIndex;
    
    float fraction = sinf((index - _baseIndex) * M_PI / 2);
    [self refreshGPUImages];
    
    [_baseImageView setAlpha: 1];
    [_baseImageView setTransform: CGAffineTransformMakeTranslation(-fraction * 40, 0)];
    [_nextImageView setAlpha: fraction];
    [_nextImageView setTransform: CGAffineTransformMakeTranslation((1-fraction) * 40, 0)];
}

- (void)swapImageViews
{
    GPUImageView * v = _baseImageView;
    _baseImageView = _nextImageView;
    _nextImageView = v;
    [self bringSubviewToFront:_nextImageView];
}

- (void)refreshGPUImages
{
    // unregister from notifications
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // get images
    NSURL * baseURL = [_delegate urlForSiteAtIndex: _baseIndex];
    UIImage * baseImage = [[PVImageCacheManager shared] imageForURL: baseURL];
    NSURL * nextURL = [_delegate urlForSiteAtIndex: _nextIndex];
    UIImage * nextImage = [[PVImageCacheManager shared] imageForURL: nextURL];
    
    // register for image updates if one is missing
    if (!baseImage)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGPUImages) name:NOTIF_IMAGE_READY object: baseURL];
    if (!nextImage)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGPUImages) name:NOTIF_IMAGE_READY object: nextURL];
    
    CGSize size = CGSizeMake(_imageViewRect.size.width / 5, _imageViewRect.size.height / 5);

    if ((_basePicture == nil) && (baseImage)) {
        _basePicture = [[GPUImagePicture alloc] initWithImage:baseImage smoothlyScaleOutput: NO];
        [self configureFiltersOnPicture:_basePicture ofSize:size forTarget:_baseImageView];
        [_basePicture processImage];
    }
    
    if ((_nextPicture == nil) && (nextImage)) {
        _nextPicture = [[GPUImagePicture alloc] initWithImage:nextImage smoothlyScaleOutput: NO];
        [self configureFiltersOnPicture:_nextPicture ofSize:size forTarget:_nextImageView];
        [_nextPicture processImage];
    }
}

- (void)configureFiltersOnPicture:(GPUImagePicture*)picture ofSize:(CGSize)size forTarget:(GPUImageView*)target
{
    [picture removeAllTargets];
    
    GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];

    [blurFilter setBlurSize: 0.7];
    [blurFilter forceProcessingAtSize: size];
    [picture addTarget: blurFilter];
    [blurFilter addTarget: brightnessFilter];
    
    [brightnessFilter setBrightness: -0.3];
    [brightnessFilter forceProcessingAtSize: size];
    [brightnessFilter addTarget: target];
}

@end
