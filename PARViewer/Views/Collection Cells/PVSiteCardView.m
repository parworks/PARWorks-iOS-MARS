//
//  PVSiteCardView.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "EPUtil.h"
#import "PVSiteCardView.h"
#import "PVImageCacheManager.h"
#import "PVTrendingSitesController.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+ThemeAdditions.h"

#define kPVCardShingleWidth 205
#define kPVCardShingleHeight 70
#define kPVSiteCardPosterWidth 250
#define kPVSiteCardPosterHeight 240

#define kRopeDistanceFromCenter 69

@implementation PVSiteCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setClipsToBounds: NO];
        [self.layer setCornerRadius: 5];
        
        CGRect posterFrame = CGRectMake(0, 0, kPVSiteCardPosterWidth, kPVSiteCardPosterHeight);
        CGPathRef shadowPath = [EPUtil newPathForRoundedRect: posterFrame radius: 5];
        self.posterContainer = [[UIView alloc] initWithFrame: posterFrame];
        _posterContainer.backgroundColor = [UIColor clearColor];
        _posterContainer.layer.shadowOffset = CGSizeMake(0, 2.5);
        _posterContainer.layer.shadowRadius = 4;
        _posterContainer.layer.shadowOpacity = 0.7;
        _posterContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
        _posterContainer.layer.cornerRadius = 5;
        _posterContainer.layer.shadowPath = shadowPath;
        [self addSubview:_posterContainer];
        CGPathRelease(shadowPath);
        
        self.posterImageView = [[ARAugmentedView alloc] initWithFrame: posterFrame];
        self.posterImageView.animateOutlineViewDrawing = NO;
        self.posterImageView.showOutlineViewsOnly = YES;
        self.posterImageView.overlayImageViewContentMode = UIViewContentModeScaleAspectFill;
        self.posterImageView.userInteractionEnabled = NO;
        self.posterImageView.layer.cornerRadius = 5;
        self.posterImageView.clipsToBounds = YES;
        [_posterContainer addSubview: _posterImageView];
    
        CAShapeLayer * l = [CAShapeLayer layer];
        
        // white top border
        [l setFrame: CGRectMake(-1, 0.2, posterFrame.size.width + 2, posterFrame.size.height + 2)];
        [l setBorderColor: [[UIColor colorWithWhite:1 alpha:1] CGColor]];
        [l setBorderWidth: 1];
        [l setCornerRadius: 5];
        [l setFillColor: nil];
        [self.posterImageView.layer addSublayer: l];

        // black bottom border
        l = [CAShapeLayer layer];
        [l setFrame: CGRectMake(-1, -0.2, posterFrame.size.width + 2, posterFrame.size.height)];
        [l setBorderColor: [[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
        [l setBorderWidth: 1];
        [l setCornerRadius: 5];
        [l setFillColor: nil];
        [self.posterImageView.layer addSublayer: l];
        
        _shingleView = [[PVCardShingleView alloc] init];
        _shingleView.frame = CGRectMake(23, _posterContainer.bounds.size.height + 12, _shingleView.frame.size.width, _shingleView.frame.size.height);
        [self addSubview:_shingleView];
        
        self.leftRopePoint = CGPointMake(_posterContainer.center.x - kRopeDistanceFromCenter, _posterContainer.frame.size.height - 5);
        self.rightRopePoint = CGPointMake(_posterContainer.center.x + kRopeDistanceFromCenter, _posterContainer.frame.size.height - 5);

        CGRect ropesRect = self.bounds;
        ropesRect.origin.y = _posterContainer.frame.size.height - 10;
        ropesRect.size.height = _shingleView.center.y - ropesRect.origin.y;

        self.ropeView = [[PVCardRopeView alloc] initWithFrame: ropesRect];
        _ropeView.posterView = self;
        _ropeView.shingleView = _shingleView;
        [self addSubview:_ropeView];
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
    [self.shingleView setSite: site];
    
    // set the poster image
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    if (img) {
        float scale = img.size.width / _site.posterImageOriginalWidth;
        [self.posterImageView setAugmentedPhoto: [[ARAugmentedPhoto alloc] initWithScaledImage:img atScale:scale andOverlayJSON:[_site posterImageOverlayJSON]]];
     } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object: nil];
    }
}

- (void)siteImageReady:(NSNotification*)notif
{
    if (![[notif object] isEqual: [_site posterImageURL]])
        return;
    
    UIImage * img = [[PVImageCacheManager shared] imageForURL: [_site posterImageURL]];
    float scale = img.size.width / _site.posterImageOriginalWidth;
    [self.posterImageView setAugmentedPhoto: [[ARAugmentedPhoto alloc] initWithScaledImage:img atScale:scale andOverlayJSON:[_site posterImageOverlayJSON]]];
}

- (void)setShingleOffset:(CGPoint)offset andRotation:(float)rotation
{
    // if the physics simulation gives us an offset of more than 75px to the left or right,
    // the user will see onscreen shingles disappearing because of cell reuse. We're allowing the
    // shingles to be out of frame by 65px...
    offset.x = fmaxf(-75, fminf(75, offset.x));
    
    offset = CGPointMake(offset.x/1.5, offset.y/1.3);
    CGPoint shingleCenter = CGPointMake(self.posterContainer.center.x - offset.x, self.posterContainer.center.y - offset.y + 100);
    CGAffineTransform shingleTransform = CGAffineTransformMakeRotation(roundf(rotation * 1000.0) / 1000.0);
    
    if (!CGPointEqualToPoint(shingleCenter, self.shingleView.center) || !CGAffineTransformEqualToTransform(self.shingleView.transform, shingleTransform)) {
        [self.shingleView setCenter: shingleCenter];
        [self.shingleView setTransform: shingleTransform];
        [_ropeView setNeedsDisplay];
    }
}

- (void)prepareForReuse
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self.posterImageView setAugmentedPhoto: nil];
    [super prepareForReuse];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end




@implementation PVCardShingleView 

- (id)init
{
    CGRect frame = CGRectMake(0, 0, kPVCardShingleWidth, kPVCardShingleHeight);
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * backgroundView = [[UIImageView alloc] initWithFrame: self.bounds];
        backgroundView.image =  [UIImage imageNamed: @"shingle_background.png"];
        [self addSubview: backgroundView];
    
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [self addSubview:_logoView];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        _nameLabel.shadowOffset = CGSizeMake(0, -1);
        _nameLabel.font = [UIFont boldParworksFontWithSize: 21];
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview: _nameLabel];
        
        self.augmentationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _augmentationLabel.backgroundColor = [UIColor clearColor];
        _augmentationLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _augmentationLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        _augmentationLabel.shadowOffset = CGSizeMake(0, -1);
        _augmentationLabel.font = [UIFont parworksFontWithSize: 12];
        [self addSubview:_augmentationLabel];
        
        self.leftRopePoint = CGPointMake(self.center.x - kRopeDistanceFromCenter, 5);
        self.rightRopePoint = CGPointMake(self.center.x + kRopeDistanceFromCenter, 5);

        self.layer.shadowOffset = CGSizeMake(0, 2.5);
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float labelPaddingLeft = 0;
    if (_site.logoURL) {
        labelPaddingLeft = _logoView.frame.size.width;
        _logoView.frame = CGRectMake(7, 14, _logoView.frame.size.width, _logoView.frame.size.height);
    }
    _nameLabel.frame = CGRectMake(10 + labelPaddingLeft, 11, kPVCardShingleWidth - 22 - labelPaddingLeft, 35);
    _nameLabel.textAlignment = _site.logoURL ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    _augmentationLabel.frame = CGRectMake(10 + labelPaddingLeft, 37, kPVCardShingleWidth - 22 - labelPaddingLeft, 24);
    _augmentationLabel.textAlignment = _site.logoURL ? NSTextAlignmentLeft : NSTextAlignmentCenter;
}

- (void)setSite:(ARSite *)site
{
    _site = site;
    _nameLabel.text = _site.name;
    _augmentationLabel.text = [NSString stringWithFormat: @"%lu Augmented Photos", _site.totalAugmentedImages];
    [_logoView setImageWithURL: _site.logoURL];
}

@end



@implementation PVCardRopeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_posterView && _shingleView) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGPoint convertedPosterLeft = [self convertPoint:_posterView.leftRopePoint fromView:_posterView];
        CGPoint convertedPosterRight = [self convertPoint:_posterView.rightRopePoint fromView:_posterView];
        CGPoint convertedShingleLeft = [self convertPoint:_shingleView.leftRopePoint fromView:_shingleView];
        CGPoint convertedShingleRight = [self convertPoint:_shingleView.rightRopePoint fromView:_shingleView];

        CGContextFillEllipseInRect(context, CGRectMake(convertedPosterLeft.x - 2, convertedPosterLeft.y - 4, 4, 4));
        CGContextFillEllipseInRect(context, CGRectMake(convertedPosterRight.x - 2, convertedPosterRight.y - 4, 4, 4));

        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.5].CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextMoveToPoint(context, convertedPosterLeft.x - 0.5, convertedPosterLeft.y - 0.5);
        CGContextAddLineToPoint(context, convertedShingleLeft.x - 0.5, convertedShingleLeft.y - 0.5);
        CGContextStrokePath(context);
        CGContextMoveToPoint(context, convertedPosterRight.x - 0.5, convertedPosterRight.y - 0.5);
        CGContextAddLineToPoint(context, convertedShingleRight.x - 0.5, convertedShingleRight.y - 0.5);
        CGContextStrokePath(context);
    }
}

@end