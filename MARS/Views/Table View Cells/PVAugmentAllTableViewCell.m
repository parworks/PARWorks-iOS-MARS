//
//  PVAugmentAllTableViewCell.m
//  MARS
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

#import "PVAugmentAllTableViewCell.h"
#import "UIColor+ThemeAdditions.h"
#import "UIFont+ThemeAdditions.h"

@implementation PVAugmentAllTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor: [UIColor colorWithWhite:0.88 alpha:1]];
        [self setSelectionStyle: UITableViewCellSelectionStyleNone];
        
        self.whiteLayer = [CAShapeLayer layer];
        _whiteLayer.shadowColor = [[UIColor blackColor] CGColor];
        _whiteLayer.shadowOffset = CGSizeMake(0, 2);
        _whiteLayer.shadowRadius = 3;
        _whiteLayer.shadowOpacity = 0.2;
        _whiteLayer.shouldRasterize = YES;
        _whiteLayer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.layer insertSublayer:_whiteLayer atIndex:0];
        
        [self textLabel].font = [UIFont boldParworksFontWithSize: 18];
        [self detailTextLabel].font = [UIFont parworksFontWithSize: 14];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel setFrame: CGRectMake(20, 8, 280, 30)];
    [self.textLabel setBackgroundColor: [UIColor clearColor]];
    
    CGRect whiteLayerFrame = self.bounds;
    whiteLayerFrame.size.height -= 8;
    [self.whiteLayer setFrame: whiteLayerFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [CATransaction setDisableActions: !animated];
    if (highlighted) {
        _whiteLayer.backgroundColor = [[UIColor parworksSelectionBlue] CGColor];
    } else {
        _whiteLayer.backgroundColor = [[UIColor colorWithWhite:0.96 alpha:1] CGColor];
    }
}

@end
