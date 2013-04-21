//
//  UINavigationItem+PVAdditions.m
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
    [titleLabel setFont: [UIFont boldParworksFontWithSize:20]];
    [titleLabel setBackgroundColor: [UIColor clearColor]];
    [titleLabel setShadowColor: [UIColor whiteColor]];
    [titleLabel setShadowOffset: CGSizeMake(0,1)];
    [titleLabel setText: title];
    [view addSubview: titleLabel];

    self.titleView = view;
}

@end
