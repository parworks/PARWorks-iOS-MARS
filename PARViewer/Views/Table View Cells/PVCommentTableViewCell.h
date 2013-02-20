//
//  PVCommentTableViewCell.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/3/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSiteComment.h"

@protocol PVCommentTableViewCellDelegate;

@interface PVCommentTableViewCell : UITableViewCell<UIActionSheetDelegate>{
    CALayer * _borderLayer;
    BOOL _first;
}

@property (nonatomic, weak) id<PVCommentTableViewCellDelegate> delegate;
@property (nonatomic, strong) ARSiteComment *comment;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *removeButton;

- (void)setIsFirstRow:(BOOL)first;

@end


@protocol PVCommentTableViewCellDelegate <NSObject>

@required
- (void)removeComment:(ARSiteComment*)comment atIndexPath:(NSIndexPath*)indexPath;
@end