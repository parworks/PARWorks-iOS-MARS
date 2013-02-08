//
//  PVFeaturedTagCell.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBorderedWhiteCell.h"
#import "UIColor+ThemeAdditions.h"
#import "UIFont+ThemeAdditions.h"

@implementation PVBorderedWhiteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self textLabel] setBackgroundColor: [UIColor clearColor]];
        [[self textLabel] setFont: [UIFont parworksFontWithSize: 16]];

        [self setSelectedBackgroundView: nil];
        [self setSelectionStyle: nil];

        _borderLayer = [CAShapeLayer layer];
        [_borderLayer setBorderWidth: 1];
        [[self layer] addSublayer: _borderLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = [self bounds];
    frame.origin.y = _first ? 0 : -1;
    frame.size.height = frame.size.height + (_first ? 1 : 2);
    [_borderLayer setFrame: frame];
    
    CGRect textFrame = [self bounds];
    textFrame.origin.x = 15;
    [[self textLabel] setFrame: textFrame];
}

- (void)setIsFirstRow:(BOOL)first
{
    _first = first;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self setBackgroundColor: [UIColor parworksSelectionBlue]];
        [[self textLabel] setTextColor: [UIColor colorWithWhite:1 alpha:1]];
        [_borderLayer setBorderColor: [[UIColor colorWithWhite:0 alpha:0.2] CGColor]];
    } else {
        [self setBackgroundColor: [UIColor whiteColor]];
        [[self textLabel] setTextColor: [UIColor colorWithWhite:0.15 alpha:1]];
        [_borderLayer setBorderColor: [[UIColor colorWithWhite:0.85 alpha:1] CGColor]];
    }
    [self setNeedsDisplay];
}

@end
