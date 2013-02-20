//
//  PVButton.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/19/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVButton.h"

@implementation PVButton

- (void)setup
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.alpha = 0.0;
    [self addSubview:_activityIndicator];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_activityIndicator setFrame:CGRectMake(0, 0, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height)];
    _activityIndicator.center = CGPointMake(self.bounds.size.width / 2, (self.bounds.size.height / 2) - 2);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setAlpha: _isAnimating ? 0 : 1];
    [self.titleLabel setAlpha: _isAnimating ? 0 : 1];
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    _isAnimating = isAnimating;
    __weak PVButton *__self = self;
    if(_isAnimating){
        [_activityIndicator startAnimating];
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            __self.imageView.alpha = 0.0;
            __self.titleLabel.alpha = 0.0;
            __self.activityIndicator.alpha = 1.0;
        } completion:^(BOOL finished){
          
        }];
    }
    else{
        [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
            [UIView setAnimationDelay: 0.4];
            __self.imageView.alpha = 1.0;
            __self.titleLabel.alpha = 1.0;
            __self.activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished){
            [__self.activityIndicator stopAnimating];
        }];
    }
}

@end
