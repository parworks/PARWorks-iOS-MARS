//
//  UINavigationItem+PVAdditions.h
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (PVAdditions)

- (void)setUnpaddedRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setUnpaddedLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setLeftJustifiedTitle:(NSString*)title;

@end
