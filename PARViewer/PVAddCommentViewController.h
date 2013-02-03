//
//  PVAddCommentViewController.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBaseViewController.h"

@protocol PVAddCommentViewControllerDelegate;

@interface PVAddCommentViewController : UIViewController

@property (nonatomic, assign) id <PVAddCommentViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIView *addCommentView;
@property (nonatomic, strong) IBOutlet UITextView *commentTextView;

- (void)setViewFrame:(CGRect)frame;
- (IBAction)postButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol PVAddCommentViewControllerDelegate <NSObject>

@required
- (void)postButtonPressed:(PVAddCommentViewController *)vc;
- (void)cancelButtonPressed:(PVAddCommentViewController *)vc;
@end