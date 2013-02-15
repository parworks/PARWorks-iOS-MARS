//
//  PVIntroCard.m
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVIntroCard.h"
#import "UIColor+Utils.h"

@implementation PVIntroCard

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
    CGFloat corner = 4.0;
    self.layer.cornerRadius = corner;
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 7, 8)];
    _containerView.backgroundColor = [UIColor colorWithHexRGBValue:0xf0f0f0];
    _containerView.layer.cornerRadius = corner;
    _containerView.layer.borderColor = [UIColor colorWithHexRGBValue:0xd9d9d9].CGColor;
    _containerView.layer.borderWidth = 2.0;
    [self.contentView addSubview:_containerView];
}


@end
