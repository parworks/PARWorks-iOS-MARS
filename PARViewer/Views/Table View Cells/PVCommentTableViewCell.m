//
//  PVCommentTableViewCell.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/3/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVCommentTableViewCell.h"
#import "NSString+DateConversion.h"
#import "PVImageCacheManager.h"
#import "UIFont+ThemeAdditions.h"

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
        [_nameLabel setFont:[UIFont parworksFontWithSize:15.0]];
        [self.contentView addSubview:_nameLabel];
        
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timestampLabel setBackgroundColor:[UIColor clearColor]];
        [_timestampLabel setUserInteractionEnabled:NO];
        [_timestampLabel setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
        [_timestampLabel setFont:[UIFont parworksFontWithSize:15.0]];
        [self.contentView addSubview:_timestampLabel];

        self.contentTextView = [[UITextView alloc] initWithFrame:CGRectZero];
		[_contentTextView setBackgroundColor:[UIColor clearColor]];
        [_contentTextView setTextColor:[UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
        [_contentTextView setFont:[UIFont parworksFontWithSize:15.0]];
        [_contentTextView setDataDetectorTypes:UIDataDetectorTypeAddress | UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber];
        [_contentTextView setScrollEnabled:NO];
        [_contentTextView setEditable:NO];
        [_contentTextView setClipsToBounds:YES];
        [self.contentView addSubview:_contentTextView];
        
        self.removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_removeButton setTitle:@"X" forState:UIControlStateNormal];
        [_removeButton setHidden:YES];
        [_removeButton addTarget:self action:@selector(removeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_removeButton];
        
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
}

- (void)layoutSubviews {
    [super layoutSubviews];    
    [_bgImageView setFrame:CGRectMake(10.0, 0.0, self.frame.size.width - 20.0, self.frame.size.height - 1.0)];
    [_avatarImageView setFrame:CGRectMake(_bgImageView.frame.origin.x + 10.0, 10.0, 26.0, 26.0)];
    [_nameLabel setFrame:CGRectMake(_avatarImageView.frame.origin.x + _avatarImageView.frame.size.width + 10.0, _avatarImageView.frame.origin.y - 2.0, 247.0, 22.0)];
    [_timestampLabel setFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
    
    CGSize size = [_contentTextView.text sizeWithFont:_contentTextView.font
                              constrainedToSize:CGSizeMake(247.0, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    [_contentTextView setFrame:CGRectMake(_nameLabel.frame.origin.x - 8.0, _timestampLabel.frame.origin.y + _timestampLabel.frame.size.height - 8.0, _nameLabel.frame.size.width + 16.0, size.height + 16.0)];
    
    [_removeButton setFrame:CGRectMake(_bgImageView.frame.origin.x + _bgImageView.frame.size.width - 25.0, _bgImageView.frame.origin.y + 5.0, 20.0, 20.0)];
    
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

- (void)removeButtonPressed{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Are you sure you want to remove your comment?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)setComment:(ARSiteComment *)comment
{
    if (comment == _comment)
        return;
    
    _comment = comment;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"FBId"];
    if(userId && [userId isEqualToString:_comment.userID])
        [_removeButton setHidden:NO];
    else
        [_removeButton setHidden:YES];
    
    _nameLabel.text = _comment.userName;
    _timestampLabel.text = [NSString stringWithDate:_comment.timestamp format:@"MMM d',' h':'mm aaa"];
    _contentTextView.text = _comment.body;
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=52&height=52", _comment.userID]];
    UIImage * img = [[PVImageCacheManager shared] imageForURL:imageURL];
    if (!img) {
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteImageReady:) name:NOTIF_IMAGE_READY object:imageURL];
    }
    [_avatarImageView setImage: img];
    
}

- (void)siteImageReady:(NSNotification*)notif
{
    UIImage * img = [[PVImageCacheManager shared] imageForURL:notif.object];
    [_avatarImageView setImage: img];
}

- (void)prepareForReuse
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super prepareForReuse];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == [alertView cancelButtonIndex])
        return;
    
    [_delegate removeComment:_comment atIndexPath:_indexPath];
}

@end
