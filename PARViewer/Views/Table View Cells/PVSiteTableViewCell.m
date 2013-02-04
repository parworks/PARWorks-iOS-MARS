//
//  PVSiteTableViewCell.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteTableViewCell.h"
#import "PVImageCacheManager.h"
#import "UIColor+ThemeAdditions.h"

@implementation PVSiteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // create our image view
        [self setBackgroundColor: [UIColor colorWithWhite:0.88 alpha:1]];
        [self setSelectionStyle: UITableViewCellSelectionStyleNone];

        self.whiteLayer = [CAShapeLayer layer];
        _whiteLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        _whiteLayer.shadowColor = [[UIColor blackColor] CGColor];
        _whiteLayer.shadowOffset = CGSizeMake(0, 2);
        _whiteLayer.shadowRadius = 3;
        _whiteLayer.shadowOpacity = 0.2;
        [self.layer insertSublayer:_whiteLayer atIndex:0];
        self.posterImageView = [[UIImageView alloc] init];
        [self addSubview: self.posterImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect posterImageFrame = CGRectMake(10,10,self.frame.size.width-20, 150);
    [self.posterImageView setFrame: posterImageFrame];
    [self.posterImageView setContentMode: UIViewContentModeScaleAspectFill];
    [self.posterImageView setClipsToBounds: YES];
    
    [self.textLabel setFrame: CGRectMake(20, 165, 280, 30)];
    [self.textLabel setBackgroundColor: [UIColor clearColor]];
    [self.detailTextLabel setFrame: CGRectMake(20, 195, 280, 20)];
    [self.detailTextLabel setBackgroundColor: [UIColor clearColor]];
    
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
}

- (void)siteUpdated:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL: _site.posterImageURL];
    if (!img)
        img = [UIImage imageNamed: @"missing_image_300x150"];
    [self.posterImageView setImage: img];
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
        _whiteLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
}
@end
