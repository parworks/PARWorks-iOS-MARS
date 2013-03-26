//
//  PVIntroCard.m
//  PARViewer
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

#import "PVAppDelegate.h"
#import "PVIntroCard.h"
#import "UIColor+Utils.h"
#import "UIFont+ThemeAdditions.h"
#import "UIViewAdditions.h"


@implementation PVIntroCard


#pragma mark - Lifecycle
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
    UIWindow *w = [[UIApplication sharedApplication] windows][0];
    _isiPhone5 = w.bounds.size.height > 480;
    
    CGFloat corner = 4.0;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
        
    CGFloat height = _isiPhone5 ? 490 : 400;
    self.outerCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, height)];
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
    
    self.imageView = [[UIImageView alloc] initWithFrame:_innerCard.bounds];
    _imageView.contentMode = UIViewContentModeTop;
    [_innerCard addSubview:_imageView];
}


#pragma mark - Layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    _outerCard.frame = CGRectMake((self.bounds.size.width/2) - (_outerCard.frame.size.width/2), 15, _outerCard.frame.size.width, _outerCard.frame.size.height);
}


#pragma mark - Convenience
- (NSString *)sizedAssetNameWithName:(NSString *)name
{
    if (_isiPhone5) {
        return [name stringByAppendingString:@"_4.png"];
    } else {
        return [name stringByAppendingString:@"_3.5.png"];
    }
}

#pragma mark - Getters/Setters
- (void)setCardStyle:(PVIntroCardStyle)cardStyle
{
    BOOL showCustom = NO;
    if (cardStyle == PVIntroCardStyle_1) {
        _imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"intro1"]];
        _swipeImageView.hidden = NO;
    } else if (cardStyle == PVIntroCardStyle_2) {
        _imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"intro2"]];
        _swipeImageView.hidden = YES;
    } else if (cardStyle == PVIntroCardStyle_3) {
        _imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"intro3"]];
        _swipeImageView.hidden = YES;
    } else if (cardStyle == PVIntroCardStyle_4) {
        _imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"intro4"]];
        _swipeImageView.hidden = YES;
        showCustom = YES;
    }
    
    if (showCustom) {
        self.skipButton.hidden = NO;
        self.topExampleView.hidden = NO;
        self.bottomExampleView.hidden = NO;
    } else {
        _swipeImageView.hidden = YES;
        _skipButton.hidden = YES;
        _topExampleView.hidden = YES;
        _bottomExampleView.hidden = YES;
    }
}

- (PVIntroExampleView *)topExampleView
{
    if (!_topExampleView) {
        _topExampleView = [PVIntroExampleView viewFromNIB];
        _topExampleView.imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"macbook"]];
        CGFloat offsetY = [PVAppDelegate isiPhone5] ? 62 : 55;
        _topExampleView.frame = CGRectMake(24, offsetY, _topExampleView.frame.size.width, _topExampleView.frame.size.height);
        _topExampleView.label.text = @"Macbook Keyboard";
        _topExampleView.siteName = @"macbookkeyboard";
        [_innerCard addSubview:_topExampleView];
    }
    return _topExampleView;
}

- (PVIntroExampleView *)bottomExampleView
{
    if (!_bottomExampleView) {
        _bottomExampleView = [PVIntroExampleView viewFromNIB];
        _bottomExampleView.imageView.image = [UIImage imageNamed:[self sizedAssetNameWithName:@"dollar"]];

        CGFloat offsetY = [PVAppDelegate isiPhone5] ? 240 : 190;
        _bottomExampleView.frame = CGRectMake(24, offsetY, _bottomExampleView.frame.size.width, _bottomExampleView.frame.size.height);
        _bottomExampleView.label.text = @"Dollar Bill";
        _bottomExampleView.siteName = @"Dollar1";
        [_innerCard addSubview:_bottomExampleView];
    }
    return _bottomExampleView;
}


- (UIButton *)skipButton
{
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.backgroundColor = [UIColor whiteColor];
        _skipButton.frame = CGRectMake(10, _innerCard.bounds.size.height - 10 - 48, _innerCard.bounds.size.width - 20, 48);
        _skipButton.titleLabel.font = [UIFont boldParworksFontWithSize:20];
        _skipButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        _skipButton.layer.borderColor = [UIColor colorWithHexRGBValue:0xdbdbdb].CGColor;
        _skipButton.layer.borderWidth = 1.0;
        _skipButton.layer.cornerRadius = 6.0;
        [_skipButton setTitle:@"Skip" forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor colorWithHexRGBValue:0x31649D] forState:UIControlStateNormal];
        [_skipButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skipButtonTouchDown) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragInside|UIControlEventTouchDragEnter];
        [_skipButton addTarget:self action:@selector(skipButtonTouchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside|UIControlEventTouchDragExit|UIControlEventTouchCancel];
        [_innerCard addSubview:_skipButton];
    }
    return _skipButton;
}

- (UIImageView *)swipeImageView
{
    if (!_swipeImageView) {
        _swipeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipe_gesture"]];
        _swipeImageView.center = CGPointMake(_innerCard.frame.size.width/2, _innerCard.frame.size.height - 40);
        [_innerCard addSubview:_swipeImageView];
    }
    return _swipeImageView;
}

- (void)skipButtonTouchDown
{
    _skipButton.backgroundColor = [UIColor colorWithHexRGBValue:0x31649d];
    [_skipButton setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
    [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}


- (void)skipButtonTouchUp
{
    _skipButton.backgroundColor = [UIColor whiteColor];
    [_skipButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_skipButton setTitleColor:[UIColor colorWithHexRGBValue:0x31649D] forState:UIControlStateNormal];
}

@end
