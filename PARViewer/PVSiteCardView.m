//
//  PVSiteCardView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteCardView.h"
#import "PVImageCacheManager.h"
#import "PVTrendingSitesController.h"

@implementation PVSiteCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor whiteColor]];
        
        self.posterImageView = [[UIImageView alloc] initWithFrame: self.bounds];
        self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterImageView.clipsToBounds = YES;
        self.posterImageView.layer.cornerRadius = 5;
        [self addSubview: _posterImageView];

        self.layer.shadowOffset = CGSizeMake(0, 2.5);
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.cornerRadius = 5;
        self.layer.shadowPath = [self newPathForRoundedRect: self.layer.bounds radius: 5];
        CAShapeLayer * l = [CAShapeLayer layer];
        
        // white top border
        [l setFrame: CGRectMake(-1, 0.2, frame.size.width + 2, frame.size.height + 2)];
        [l setBorderColor: [[UIColor colorWithWhite:1 alpha:1] CGColor]];
        [l setBorderWidth: 1];
        [l setCornerRadius: 5];
        [l setFillColor: nil];
        [self.posterImageView.layer addSublayer: l];

        // black bottom border
        l = [CAShapeLayer layer];
        [l setFrame: CGRectMake(-1, -0.2, frame.size.width + 2, frame.size.height)];
        [l setBorderColor: [[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
        [l setBorderWidth: 1];
        [l setCornerRadius: 5];
        [l setFillColor: nil];
        [self.posterImageView.layer addSublayer: l];

    }
    return self;
}

- (ARSite*)site
{
    return _site;
}

- (void)setSite:(ARSite*)site
{
    // stop listening for image availability
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    _site = site;
    
    // set the poster image
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    if (!img) {
        img = [UIImage imageNamed: @"empty.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object: [_site posterImageURL]];
    }
    [self.posterImageView setImage: img];
}

- (void)siteImageReady:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    [self.posterImageView setImage: img];
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}


@end
