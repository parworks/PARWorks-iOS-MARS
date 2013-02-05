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

#define kPVCardShingleWidth 205
#define kPVCardShingleHeight 70
#define kPVSiteCardPosterWidth 250
#define kPVSiteCardPosterHeight 240

@implementation PVSiteCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self setClipsToBounds: NO];
        [self.layer setCornerRadius: 5];
        
        CGRect posterFrame = CGRectMake(0, 0, kPVSiteCardPosterWidth, kPVSiteCardPosterHeight);
        self.posterContainer = [[UIView alloc] initWithFrame: posterFrame];
        _posterContainer.backgroundColor = [UIColor clearColor];
        _posterContainer.layer.shadowOffset = CGSizeMake(0, 2.5);
        _posterContainer.layer.shadowRadius = 4;
        _posterContainer.layer.shadowOpacity = 0.7;
        _posterContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
        _posterContainer.layer.cornerRadius = 5;
        _posterContainer.layer.shadowPath = [self newPathForRoundedRect: posterFrame radius: 5];
        [self addSubview:_posterContainer];
        
        self.posterImageView = [[UIImageView alloc] initWithFrame: _posterContainer.bounds];
        self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.posterImageView.clipsToBounds = YES;
        self.posterImageView.layer.cornerRadius = 5;
        [_posterContainer addSubview: _posterImageView];
    
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
        
        _shingleView = [[PVCardShingleView alloc] init];
        _shingleView.frame = CGRectMake(18, _posterContainer.bounds.size.height + 22, _shingleView.frame.size.width, _shingleView.frame.size.height);
        [self addSubview:_shingleView];
        
        self.leftRopePoint = CGPointMake(_posterContainer.center.x - (_posterContainer.frame.size.width/3), _posterContainer.frame.size.height - 5);
        self.rightRopePoint = CGPointMake(_posterContainer.center.x + (_posterContainer.frame.size.width/3), _posterContainer.frame.size.height - 5);
        
        self.ropeView = [[PVCardRopeView alloc] initWithFrame:CGRectInset(self.bounds, -50, 0)];
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

- (void)setShingleOffset:(CGPoint)offset andRotation:(float)rotation
{
    CGPoint shingleCenter = CGPointMake(self.posterContainer.center.x - offset.x, self.posterContainer.center.y - offset.y + 100);
    [self.shingleView setCenter: shingleCenter];
    [self.shingleView setTransform: CGAffineTransformMakeRotation(rotation)];
    [_ropeView setNeedsDisplay];
}

@end




@implementation PVCardShingleView 

- (id)init
{
    CGRect frame = CGRectMake(0, 0, kPVCardShingleWidth, kPVCardShingleHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [self addSubview:_logoView];
        NSURL *url = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/en/thumb/3/3b/Chipotle_Mexican_Grill_logo.svg/200px-Chipotle_Mexican_Grill_logo.svg.png"];
        [_logoView setImageWithURL:url];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 24)];
        _nameLabel.backgroundColor = [UIColor redColor];
        _nameLabel.text = @"<Company Name>";
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_nameLabel];
        
        self.augmentationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 24)];
        _augmentationLabel.backgroundColor = [UIColor purpleColor];
        _augmentationLabel.text = @"<augmentations>";
        _augmentationLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_augmentationLabel];
        
        self.leftRopePoint = CGPointMake(self.center.x - (self.frame.size.width/3.4), 5);
        self.rightRopePoint = CGPointMake(self.center.x + (self.frame.size.width/3.4), 5);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _logoView.frame = CGRectMake(10, 15, _logoView.frame.size.width, _logoView.frame.size.height);
    _nameLabel.frame = CGRectMake(65, 20, _nameLabel.frame.size.width, _nameLabel.frame.size.height);
    _augmentationLabel.frame = CGRectMake(65, 42, _augmentationLabel.frame.size.width, _augmentationLabel.frame.size.height);
    
}

- (void)setSite:(ARSite *)site
{
    _site = site;
    
    // TODO: Set to site's logo url
    NSURL *url = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/en/thumb/3/3b/Chipotle_Mexican_Grill_logo.svg/200px-Chipotle_Mexican_Grill_logo.svg.png"];
    [_logoView setImageWithURL:url];
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
        
        draw1PxStroke(context, convertedPosterLeft, convertedShingleLeft, [UIColor orangeColor]);
        draw1PxStroke(context, convertedPosterRight, convertedShingleRight, [UIColor cyanColor]);
    }
}

@end