//
//  PVSidebarTableViewCell.m
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

#import "PVSidebarTableViewCell.h"
#import "UIColor+ThemeAdditions.h"

@implementation PVSidebarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[self textLabel] setTextColor: [UIColor whiteColor]];
        [[self textLabel] setShadowColor: [UIColor colorWithWhite:0 alpha:0.5]];
        [[self textLabel] setBackgroundColor: [UIColor clearColor]];
        [self setSelectedBackgroundView: nil];
        [self setSelectionStyle: nil];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();

    if (self.selected) {
        CGRect fillRect = rect;
        fillRect.size.height = rect.size.height - 1;
        CGContextSetFillColorWithColor(c, [[UIColor parworksSelectionBlue] CGColor]);
        CGContextFillRect(c, fillRect);
    }
    
    // top line
    float y = 0.5;
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:1 alpha:0.08] CGColor]);
    CGContextMoveToPoint(c, 0, y);
    CGContextAddLineToPoint(c, rect.size.width, y);
    CGContextStrokePath(c);

    // bottom line
    y = rect.size.height - 0.5;
    CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0 alpha:0.35] CGColor]);
    CGContextMoveToPoint(c, 0, y);
    CGContextAddLineToPoint(c, rect.size.width, y);
    CGContextStrokePath(c);
}
@end
