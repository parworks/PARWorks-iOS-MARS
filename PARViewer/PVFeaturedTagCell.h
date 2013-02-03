//
//  PVFeaturedTagCell.h
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVFeaturedTagCell : UITableViewCell
{
    CALayer * _borderLayer;
    BOOL _first;
}

- (void)setIsFirstRow:(BOOL)first;

@end
