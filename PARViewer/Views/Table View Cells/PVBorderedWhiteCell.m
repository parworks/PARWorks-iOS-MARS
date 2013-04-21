//
//  PVFeaturedTagCell.m
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
