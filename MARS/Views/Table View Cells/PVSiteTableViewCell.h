//
//  PVSiteTableViewCell.h
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
