//
//  PVSidebarTableViewCell.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSidebarTableViewCell.h"

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
        CGContextSetFillColorWithColor(c, [[UIColor colorWithRed:50.0/255.0 green:98.0/255.0 blue:162.0/255.0 alpha:1] CGColor]);
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
