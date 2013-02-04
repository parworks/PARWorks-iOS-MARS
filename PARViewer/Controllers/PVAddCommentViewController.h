//
//  PVAddCommentViewController.h
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBaseViewController.h"
#import "ARSite.h"

@protocol PVAddCommentViewControllerDelegate;

@interface PVAddCommentViewController : UIViewController

@property (nonatomic, weak) id <PVAddCommentViewControllerDelegate> delegate;
@property (nonatomic, strong) ARSite * site;
@property (nonatomic, weak) IBOutlet UIView *addCommentView;
@property (nonatomic, weak) IBOutlet UITextView *commentTextView;

- (IBAction)postButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol PVAddCommentViewControllerDelegate <NSObject>

@required
- (void)postedCommentSuccessfully:(PVAddCommentViewController *)vc;
- (void)cancelButtonPressed:(PVAddCommentViewController *)vc;
@end