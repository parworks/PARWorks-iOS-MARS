//
//  PVCommentTableViewCell.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/3/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVCommentTableViewCell.h"

@implementation PVCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_bgImageView setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]];
        [_bgImageView setUserInteractionEnabled:NO];
        [self.contentView addSubview:_bgImageView];
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_avatarImageView setBackgroundColor:[UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0]];
        [_avatarImageView.layer setBorderColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor];
        [_avatarImageView.layer setBorderWidth:1.0];
        [_avatarImageView setUserInteractionEnabled:NO];
        [self.contentView addSubview:_avatarImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setUserInteractionEnabled:NO];
        [_nameLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
        [_nameLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self.contentView addSubview:_nameLabel];
        
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timestampLabel setBackgroundColor:[UIColor clearColor]];
        [_timestampLabel setUserInteractionEnabled:NO];
        [_timestampLabel setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
        [_timestampLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self.contentView addSubview:_timestampLabel];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setUserInteractionEnabled:NO];
        [_contentLabel setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
        [_contentLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_contentLabel setNumberOfLines:0];
        [_contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentView addSubview:_contentLabel];
        
        _borderLayer = [CAShapeLayer layer];
        [_borderLayer setBorderWidth: 1];
        [_borderLayer setBorderColor: [[UIColor colorWithWhite:0.85 alpha:1] CGColor]];
        [[self layer] addSublayer: _borderLayer];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_bgImageView setFrame:CGRectMake(10.0, 0.0, self.frame.size.width - 20.0, self.frame.size.height)];
    [_avatarImageView setFrame:CGRectMake(_bgImageView.frame.origin.x + 10.0, 10.0, 26.0, 26.0)];
    [_nameLabel setFrame:CGRectMake(_avatarImageView.frame.origin.x + _avatarImageView.frame.size.width + 10.0, _avatarImageView.frame.origin.y - 2.0, 247.0, 18.0)];
    [_timestampLabel setFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
    
    CGSize size = [_contentLabel.text sizeWithFont:_contentLabel.font
                              constrainedToSize:CGSizeMake(247.0, MAXFLOAT)
                                  lineBreakMode:UILineBreakModeWordWrap];
    [_contentLabel setFrame:CGRectMake(_nameLabel.frame.origin.x, _timestampLabel.frame.origin.y + _timestampLabel.frame.size.height, _nameLabel.frame.size.width, size.height)];
    
    CGRect frame = [_bgImageView frame];
    frame.origin.y = _first ? 0 : -1;
    frame.size.height = frame.size.height + (_first ? 1 : 2);
    [_borderLayer setFrame: frame];       
}

- (void)setIsFirstRow:(BOOL)first
{
    _first = first;
    [self setNeedsLayout];
}

- (void)setComment:(ARSiteComment *)comment{
    _comment = comment;
    _nameLabel.text = _comment.userName;
    _timestampLabel.text = [NSString stringWithFormat:@"%@", _comment.timestamp];
    _contentLabel.text = _comment.body;
}

@end
