//
//  PVAddCommentViewController.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVAddCommentViewController.h"

@interface PVAddCommentViewController ()

@end

@implementation PVAddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self slideIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setViewFrame:(CGRect)frame{
    [self.view setFrame:frame];
//    [_vBackground setFrame:self.view.frame];
//    [_vContainer setFrame:CGRectMake(_vContainer.frame.origin.x, _vContainer.frame.origin.y, _vContainer.frame.size.width, _vContainer.frame.size.height)];
//    _vContainer.center = _vBackground.center;
}

- (void)slideIn{
    _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, -_addCommentView.frame.size.height, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
    UITextView * __weak __commentTextView = _commentTextView;
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, 50.0, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
        [__commentTextView becomeFirstResponder];
    } completion:nil];
}

- (void)slideOut{
    UITextView * __weak __commentTextView = _commentTextView;
    [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, -_addCommentView.frame.size.height, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
        [__commentTextView resignFirstResponder];
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
    }];
}

- (IBAction)postButtonPressed:(id)sender{
    [self slideOut];
    [_delegate postButtonPressed:self];
}

- (IBAction)cancelButtonPressed:(id)sender{
    [self slideOut];
    [_delegate cancelButtonPressed:self];
}

@end
