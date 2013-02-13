//
//  PVSiteTableViewCell.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARAugmentedView.h"
#import "ARTotalAugmentedImagesView.h"
#import "PVSiteTableViewCell.h"
#import "PVImageCacheManager.h"
#import "UIColor+ThemeAdditions.h"
#import "UIFont+ThemeAdditions.h"
#import "ARManager.h"

@implementation PVSiteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // create our image view
        [self setBackgroundColor: [UIColor colorWithWhite:0.88 alpha:1]];
        [self setSelectionStyle: UITableViewCellSelectionStyleNone];

        self.whiteLayer = [CAShapeLayer layer];
        _whiteLayer.shadowColor = [[UIColor blackColor] CGColor];
        _whiteLayer.shadowOffset = CGSizeMake(0, 2);
        _whiteLayer.shadowRadius = 3;
        _whiteLayer.shadowOpacity = 0.2;
        _whiteLayer.shouldRasterize = YES;
        _whiteLayer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.layer insertSublayer:_whiteLayer atIndex:0];
        
        
        self.posterImageView = [[ARAugmentedView alloc] initWithFrame: CGRectZero];
        _posterImageView.clipsToBounds = YES;
        _posterImageView.animateOutlineViewDrawing = NO;
        _posterImageView.showOutlineViewsOnly = YES;
        _posterImageView.overlayImageViewContentMode = UIViewContentModeScaleAspectFill;
        _posterImageView.totalAugmentedImagesView.hidden = NO;
        _posterImageView.totalAugmentedImagesView.count = 20;
        _posterImageView.userInteractionEnabled = NO;
        _posterImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _posterImageView.layer.borderWidth = 1;
        [self addSubview: self.posterImageView];
        
        [self textLabel].font = [UIFont boldParworksFontWithSize: 18];
        [self detailTextLabel].font = [UIFont parworksFontWithSize: 14];
        
        _distanceButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [_distanceButton setBackgroundImage:[UIImage imageNamed:@"nearby_site_icon.png"] forState: UIControlStateNormal];
        [_distanceButton setTitleEdgeInsets: UIEdgeInsetsMake(27, 10, 0, 0)];
        [_distanceButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_distanceButton setUserInteractionEnabled: NO];
        [[_distanceButton titleLabel] setFont: [UIFont parworksFontWithSize: 12]];
        [self.contentView addSubview: _distanceButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.posterImageView setFrame: CGRectMake(10,10,self.frame.size.width-20, 150)];
    [self.textLabel setFrame: CGRectMake(20, 165, 280, 30)];
    [self.textLabel setBackgroundColor: [UIColor clearColor]];
    [self.detailTextLabel setFrame: CGRectMake(20, 195, 280, 20)];
    [self.detailTextLabel setBackgroundColor: [UIColor clearColor]];
    [_distanceButton setFrame: CGRectMake(self.frame.size.width - 60, 165, 50, 44)];
    
    CGRect whiteLayerFrame = self.bounds;
    whiteLayerFrame.size.height -= 8;
    [self.whiteLayer setFrame: whiteLayerFrame];
}

- (void)setSite:(ARSite*)site
{
    if (site == _site)
        return;
    
    _site = site;
    [self siteUpdated: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteUpdated:) name:NOTIF_SITE_UPDATED object:_site];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteUpdated:) name:NOTIF_IMAGE_READY object:_site.posterImageURL];

    if (_site.location.latitude != 0) {
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:_site.location.latitude longitude:_site.location.longitude];
        CLLocation *locB = [[ARManager shared] deviceLocation];
        CLLocationDistance distance = [locA distanceFromLocation:locB];
        
        // convert to miles, round to two decimal places
        double miles = roundf((distance / 1609.34) * 10.0) / 10.0;
        if (miles >= 0.1)
            [_distanceButton setTitle:[NSString stringWithFormat:@"%.1f mi", miles] forState:UIControlStateNormal];
        else
            [_distanceButton setTitle:[NSString stringWithFormat:@"%.0f m", distance] forState:UIControlStateNormal];

        [_distanceButton setHidden: NO];
    } else {
        [_distanceButton setHidden: YES];
    }
}

- (void)siteUpdated:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL: _site.posterImageURL];
    NSDictionary * overlays = _site.posterImageOverlayJSON;
    if (!img) {
        img = [UIImage imageNamed: @"missing_image_300x150.png"];
        overlays = nil;
    }
    
    float scale = img.size.width / _site.originalImageWidth;
    ARAugmentedPhoto *photo = [[ARAugmentedPhoto alloc] initWithScaledImage: img atScale: scale andOverlayJSON: overlays];
    [self.posterImageView setAugmentedPhoto: photo];
    [self.posterImageView.totalAugmentedImagesView setCount:_site.totalAugmentedImages];
    [self.textLabel setText: [_site name] ? [_site name] : @"Loading..."];
    [self.detailTextLabel setText: @"Hiya"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [CATransaction setDisableActions: !animated];
    if (highlighted) {
        _whiteLayer.backgroundColor = [[UIColor parworksSelectionBlue] CGColor];
    } else {
        _whiteLayer.backgroundColor = [[UIColor colorWithWhite:0.96 alpha:1] CGColor];
    }
}

- (void)prepareForReuse
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super prepareForReuse];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
