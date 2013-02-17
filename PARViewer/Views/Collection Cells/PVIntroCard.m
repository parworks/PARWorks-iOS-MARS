//
//  PVIntroCard.m
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVIntroCard.h"
#import "UIColor+Utils.h"
#import "UIViewAdditions.h"

@implementation PVIntroCard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    CGFloat corner = 4.0;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    self.outerCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 390)];
    _outerCard.userInteractionEnabled = YES;
    _outerCard.backgroundColor = [UIColor whiteColor];
    _outerCard.layer.cornerRadius = corner;
    _outerCard.layer.shadowColor = [UIColor blackColor].CGColor;
    _outerCard.layer.shadowOffset = CGSizeMake(0, 1);
    _outerCard.layer.shadowOpacity = 1.0;
    _outerCard.layer.shadowRadius = 1.0;
    _outerCard.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _outerCard.layer.shouldRasterize = YES;
    [self addSubview:_outerCard];
    
    self.innerCard = [[UIView alloc] initWithFrame:CGRectInset(_outerCard.bounds, 7, 8)];
    _innerCard.userInteractionEnabled = YES;
    _innerCard.backgroundColor = [UIColor colorWithHexRGBValue:0xf0f0f0];
    _innerCard.layer.cornerRadius = corner;
    _innerCard.layer.borderColor = [UIColor colorWithHexRGBValue:0xd9d9d9].CGColor;
    _innerCard.layer.borderWidth = 2.0;
    _innerCard.clipsToBounds = YES;
    [self.outerCard addSubview:_innerCard];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foo)];
    [self addGestureRecognizer:tap];
}

- (void)foo
{
    NSLog(@"%@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _outerCard.frame = CGRectMake((self.bounds.size.width/2) - (_outerCard.frame.size.width/2), 15, _outerCard.frame.size.width, _outerCard.frame.size.height);
}

- (void)setCardStyle:(PVIntroCardStyle)cardStyle
{
    if (cardStyle == PVIntroCardStyle_1) {
        _skipButton.hidden = YES;
    } else if (cardStyle == PVIntroCardStyle_2) {
        _skipButton.hidden = YES;
    } else if (cardStyle == PVIntroCardStyle_3) {
        self.skipButton.hidden = NO;
    }
}

- (UIButton *)skipButton
{
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _skipButton.frame = CGRectMake(10, _innerCard.bounds.size.height - 10 - 48, _innerCard.bounds.size.width - 20, 48);
        [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [_skipButton setUserInteractionEnabled:YES];
        [_innerCard addSubview:_skipButton];
    }
    return _skipButton;
}

@end
