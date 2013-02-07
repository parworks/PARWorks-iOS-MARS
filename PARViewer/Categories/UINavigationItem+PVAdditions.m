//
//  UINavigationItem+PVAdditions.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UINavigationItem+PVAdditions.h"
#import "UIFont+ThemeAdditions.h"

@implementation UINavigationItem (PVAdditions)

- (void)setUnpaddedLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    [self setLeftBarButtonItems: [NSArray arrayWithObjects:negativeSpacer, item, nil] animated:animated];
}

- (void)setUnpaddedRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    
    [self setRightBarButtonItems: [NSArray arrayWithObjects:negativeSpacer, item, nil] animated:animated];
}

- (void)setLeftJustifiedTitle:(NSString*)title
{
    CGRect frame = CGRectMake(8.0, 2.0, 320.0, 40.0);
    UIView *view = [[UIView alloc] initWithFrame: frame];

    UILabel * titleLabel = [[UILabel alloc] initWithFrame: frame];
    [titleLabel setTextColor: [UIColor colorWithWhite:0.2 alpha:1]];
    [titleLabel setFont: [UIFont parworksFontWithSize:20]];
    [titleLabel setBackgroundColor: [UIColor clearColor]];
    [titleLabel setShadowColor: [UIColor whiteColor]];
    [titleLabel setShadowOffset: CGSizeMake(0,1)];
    [titleLabel setText: title];
    [view addSubview: titleLabel];

    self.titleView = view;
}

@end
