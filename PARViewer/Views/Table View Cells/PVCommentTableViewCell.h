//
//  PVCommentTableViewCell.h
//  PARViewer
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