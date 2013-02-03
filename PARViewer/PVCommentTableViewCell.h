//
//  PVCommentTableViewCell.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/3/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSiteComment.h"

@interface PVCommentTableViewCell : UITableViewCell{
    CALayer * _borderLayer;
    BOOL _first;
}

@property (nonatomic, strong) ARSiteComment *comment;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timestampLabel;
//@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITextView *contentTextView;

- (void)setIsFirstRow:(BOOL)first;

@end
