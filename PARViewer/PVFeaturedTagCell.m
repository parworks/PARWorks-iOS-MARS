//
//  PVFeaturedTagCell.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVFeaturedTagCell.h"

@implementation PVFeaturedTagCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor: [UIColor whiteColor]];
        [[self textLabel] setBackgroundColor: [UIColor clearColor]];
        [[self textLabel] setFont: [UIFont fontWithName:@"HiraKakuProN-W3" size:16]];

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
    textFrame.origin.y += 5;
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
        [[self textLabel] setTextColor: [UIColor colorWithWhite:1 alpha:1]];
        [_borderLayer setBorderColor: [[UIColor colorWithWhite:0 alpha:0.2] CGColor]];
    } else {
        [[self textLabel] setTextColor: [UIColor colorWithWhite:0.15 alpha:1]];
        [_borderLayer setBorderColor: [[UIColor colorWithWhite:0.85 alpha:1] CGColor]];
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    if (self.highlighted) {
        CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:50.0/255.0 green:98.0/255.0 blue:162.0/255.0 alpha:1] CGColor]);
        CGContextFillRect(c, rect);
    }
}

@end
