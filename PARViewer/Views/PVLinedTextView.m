//
//  PVLinedTextView.m
//  PARViewer
//
//  Created by Ben Gotow on 2/8/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVLinedTextView.h"

@implementation PVLinedTextView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextBeginPath(context);
    
    //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
    NSUInteger numberOfLines = (self.contentSize.height + self.bounds.size.height) / self.font.leading;
    
    //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
    CGFloat baselineOffset = 5.0f;
    
    //iterate over numberOfLines and draw each line
    for (int x = 0; x < numberOfLines; x++) {
        //0.5f offset lines up line with pixel boundary
        CGContextMoveToPoint(context, self.bounds.origin.x, self.font.leading*x + 0.5f + baselineOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.font.leading*x + 0.5f + baselineOffset);
    }
    
    //Close our Path and Stroke (draw) it
    CGFloat dash[] = {0.0, 2.0};
    CGContextSetLineDash(context, 0, dash, 2);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
}

@end
