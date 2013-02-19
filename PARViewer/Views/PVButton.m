//
//  PVButton.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/19/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVButton.h"

@implementation PVButton

- (void)setup{
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

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [_activityIndicator setFrame:CGRectMake(0, 0, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height)];
    _activityIndicator.center = self.center;
}

- (void)setIsAnimating:(BOOL)isAnimating{
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
            __self.imageView.alpha = 1.0;
            __self.titleLabel.alpha = 1.0;
            __self.activityIndicator.alpha = 0.0;
        } completion:^(BOOL finished){
            [__self.activityIndicator stopAnimating];
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
