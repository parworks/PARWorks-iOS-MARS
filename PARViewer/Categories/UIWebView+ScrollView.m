//
//  UIWebView+ScrollView.m
//  PARViewer
//
//  Created by Demetri Miller on 2/10/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UIWebView+ScrollView.h"

@implementation UIWebView (ScrollView)

- (void)removeShadows
{
    for (UIView *subview in self.scrollView.subviews) {
        if([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
}

@end
