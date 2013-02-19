//
//  PVLoadingView.m
//  LoadingView
//
//  Created by Ben Gotow on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVLoadingView.h"

@implementation PVLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    _block1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15,15)];
    _block1.layer.cornerRadius = 10;
    _block1.transform = CGAffineTransformMakeRotation(M_PI / 100);
    [self addSubview: _block1];
    
    _block2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15,15)];
    _block2.layer.cornerRadius = 10;
    _block2.transform = CGAffineTransformMakeRotation(M_PI / 100);
    [self addSubview: _block2];
    
    [self setClipsToBounds: YES];
    [self setBackgroundColor: [UIColor clearColor]];
    [self.layer setBorderWidth: 4];
    [self setAlpha: 0];
    
    [self setLoadingViewStyle:PVLoadingViewStyleWhite];
}

- (void)startAnimating
{
    [_block1 setCenter: CGPointMake(-15, self.frame.size.height + 15)];
    [_block2 setCenter: CGPointMake(self.frame.size.width + 15, -15)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 1];
    [UIView setAnimationRepeatCount: INFINITY];
    [self setTransform: CGAffineTransformMakeRotation(M_PI/2)];
    [_block1 setCenter: CGPointMake(self.frame.size.width + 15, -15)];
    [_block2 setCenter: CGPointMake(-15, self.frame.size.height + 15)];
    [UIView commitAnimations];
    
    [UIView beginAnimations: nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [self setAlpha: 1];
    [UIView commitAnimations];
}

- (void)stopAnimating
{
    [UIView beginAnimations: nil context:nil];
    [UIView setAnimationDuration: 0.3];
    [self setAlpha: 0];
    [UIView commitAnimations];
}

- (void)setLoadingViewStyle:(PVLoadingViewStyle)loadingViewStyle{
    _loadingViewStyle = loadingViewStyle;
    switch (_loadingViewStyle) {
        case PVLoadingViewStyleBlack:
            _block1.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            _block2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
            [self.layer setBorderColor: [[UIColor colorWithWhite:0 alpha:0.6] CGColor]];
            break;
        case PVLoadingViewStyleWhite:
        default:
            _block1.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
            _block2.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
            [self.layer setBorderColor: [[UIColor colorWithWhite:1 alpha:0.6] CGColor]];
            break;
    }
}

@end