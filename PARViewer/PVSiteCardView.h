//
//  PVSiteCardView.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "ARSite.h"

@interface PVSiteCardView : PSUICollectionViewCell
{
    ARSite * _site;
}

@property (nonatomic, strong) UIImageView * posterImageView;

- (void)setSite:(ARSite*)site;

@end
