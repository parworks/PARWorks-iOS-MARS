//
//  PVSiteTableViewCell.h
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSite.h"

@interface PVSiteTableViewCell : UITableViewCell
{
    ARSite * _site;
}

@property (nonatomic, strong) CALayer * whiteLayer;
@property (nonatomic, strong) UIImageView * posterImageView;

- (void)setSite:(ARSite*)site;


@end
