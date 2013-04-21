//
//  PVAddCommentViewController.h
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

#import "PVBaseViewController.h"
#import "ARSite.h"
#import "ARSiteComment.h"

@protocol PVAddCommentViewControllerDelegate;

@interface PVAddCommentViewController : UIViewController <UITextViewDelegate> {
    CGFloat _addCommentYOrigin;
}

@property (nonatomic, weak) id <PVAddCommentViewControllerDelegate> delegate;
@property (nonatomic, strong) ARSite * site;
@property (nonatomic, weak) IBOutlet UIView *addCommentView;
@property (weak, nonatomic) IBOutlet UIView *addCommentContainerView;
@property (nonatomic, weak) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (IBAction)postButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol PVAddCommentViewControllerDelegate <NSObject>

@required
- (void)postedComment:(ARSiteComment*)comment successfully:(PVAddCommentViewController *)vc;
- (void)cancelButtonPressed:(PVAddCommentViewController *)vc;
@end