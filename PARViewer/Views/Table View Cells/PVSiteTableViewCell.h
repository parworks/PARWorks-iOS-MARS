//
//  PVSiteTableViewCell.h
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSite.h"

@class ARAugmentedView;

@interface PVSiteTableViewCell : UITableViewCell
{
    ARSite * _site;
    UIButton * _distanceButton;
}

@property (nonatomic, strong) CALayer * whiteLayer;
@property (nonatomic, strong) ARAugmentedView * posterImageView;

- (void)setSite:(ARSite*)site;


@end
