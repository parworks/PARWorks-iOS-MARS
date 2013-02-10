//
//  PVAddCommentViewController.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVAddCommentViewController.h"
#import "ARSite+MARS_Extensions.h"
#import "PVAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+ThemeAdditions.h"
#import "UINavigationItem+PVAdditions.h"
#import "UINavigationBar+Additions.h"
#import "EPUtil.h"

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
    if([self isIPhone5])
        _addCommentYOrigin = 98.0;
    else
        _addCommentYOrigin = 50.0;
        
    _commentTextView.font = [UIFont parworksFontWithSize:18.0];
    
    _addCommentView.contentMode = UIViewContentModeScaleAspectFill;
    _addCommentView.layer.cornerRadius = 5;
    _addCommentView.clipsToBounds = YES;
    _addCommentContainerView.backgroundColor = [UIColor clearColor];
    _addCommentContainerView.layer.shadowOffset = CGSizeMake(0, 2.5);
    _addCommentContainerView.layer.shadowRadius = 4;
    _addCommentContainerView.layer.shadowOpacity = 0.7;
    _addCommentContainerView.layer.shadowPath = [EPUtil newPathForRoundedRect:_addCommentView.layer.bounds radius: 5];
    _addCommentContainerView.layer.shouldRasterize = YES;
    _addCommentContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    [[self.navigationBar topItem] setUnpaddedLeftBarButtonItem:[self.navigationBar topItem].leftBarButtonItem animated:NO];
    [[self.navigationBar topItem] setUnpaddedRightBarButtonItem:[self.navigationBar topItem].rightBarButtonItem animated:NO];
    [self.navigationBar addShadowEffect];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self slideIn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)slideIn{
    CGRect frame = _addCommentContainerView.frame;
    __weak UITextView *__commentTextView = _commentTextView;
    
    _addCommentContainerView.frame = CGRectMake(frame.origin.x, -frame.size.height, frame.size.width, frame.size.height);
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentContainerView.frame = CGRectMake(frame.origin.x, _addCommentYOrigin, frame.size.width, frame.size.height);
        [__commentTextView becomeFirstResponder];
    } completion:nil];
}

- (void)slideOut{
    CGRect frame = _addCommentContainerView.frame;
    __weak UITextView *__commentTextView = _commentTextView;

    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentContainerView.frame = CGRectMake(frame.origin.x, -frame.size.height, frame.size.width, frame.size.height);
        [__commentTextView resignFirstResponder];
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
    }];
}

- (IBAction)postButtonPressed:(id)sender
{
    if ([_commentTextView.text length] > 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:[defaults objectForKey:@"FBName"]forKey:@"userName"];
        [dict setObject:[defaults objectForKey:@"FBId"] forKey:@"userId"];
        [dict setObject:_commentTextView.text forKey:@"comment"];
        [dict setObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000] forKey:@"timeStamp"];
        
        ARSiteComment *newComment = [[ARSiteComment alloc] initWithDictionary:dict];
        __weak PVAddCommentViewController *__self = self;

        [_site addComment:newComment withCallback:^(NSString *err, ARSiteComment *comment){
            [__self slideOut];
            [__self.delegate postedComment:comment successfully:__self];
        }];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a comment to post."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelButtonPressed:(id)sender{
    [self slideOut];
    [_delegate cancelButtonPressed:self];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"])
        [self postButtonPressed: nil];
    return YES;
}

- (BOOL)isIPhone5
{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.window.frame.size.height == 568.0;
}

@end
