//
//  PVSiteTableViewCell.m
//  MARS
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
#import "ARAugmentedView.h"
#import "ARLoadingView.h"
#import "ARTotalAugmentedImagesView.h"
#import "PVSiteTableViewCell.h"
#import "PVImageCacheManager.h"
#import "UIColor+ThemeAdditions.h"
#import "UIFont+ThemeAdditions.h"
#import "ARManager.h"
#import "UIColor+Utils.h"

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
        _posterImageView.backgroundColor = [UIColor colorWithHexRGBValue:0xCCCCCC];
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
        
        // TODO: Removing the loading view for now since there isn't really time to make it work right...
        // We should do some caching so we show the loading view the first time
        // we attempt to load the augmented photo
        [_posterImageView.loadingView removeFromSuperview];
        
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
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    if (site == _site)
        return;
    
    _site = site;
    
    if (site) {
        [_posterImageView.loadingView setHidden:NO];
        [self siteUpdated: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteUpdated:) name:NOTIF_SITE_UPDATED object:_site];
        
        // set the poster image
        UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
        if (img) {
            float scale = img.size.width / _site.posterImageOriginalWidth;
            [self.posterImageView setAugmentedPhoto: [[ARAugmentedPhoto alloc] initWithScaledImage:img atScale:scale andOverlayJSON:[_site posterImageOverlayJSON]]];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object: nil];
        }
        
        // Set the location info
        if (_site.location.latitude != 0) {
            CLLocation *locA = [[CLLocation alloc] initWithLatitude:_site.location.latitude longitude:_site.location.longitude];
            CLLocation *locB = [[ARManager shared] deviceLocation];
            CLLocationDistance distance = [locA distanceFromLocation:locB];
            
            // convert to miles, round to two decimal places
            double miles = roundf((distance / 1609.34) * 10.0) / 10.0;
            if (miles >= 0.1)
                [_distanceButton setTitle:[NSString stringWithFormat:@"%.1f mi", miles] forState:UIControlStateNormal];
            else
                [_distanceButton setTitle:[NSString stringWithFormat:@"%.0f ft", miles * 5280.0] forState:UIControlStateNormal];
            
            [_distanceButton setHidden: NO];
        } else {
            [_distanceButton setHidden: YES];
        } 
    }
}

- (void)siteUpdated:(NSNotification*)notif
{
    [self.textLabel setText: [_site name] ? [_site name] : @"Loading..."];
}

- (void)siteImageReady:(NSNotification*)notif
{
    if (![[notif object] isEqual: [_site posterImageURL]])
        return;
    
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    float scale = img.size.width / _site.posterImageOriginalWidth;
    [self.posterImageView setAugmentedPhoto: [[ARAugmentedPhoto alloc] initWithScaledImage:img atScale:scale andOverlayJSON:[_site posterImageOverlayJSON]]];
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
    [self setSite:nil];
    [self.posterImageView setAugmentedPhoto: nil];
    [_posterImageView.loadingView setHidden:YES];
    [super prepareForReuse];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
