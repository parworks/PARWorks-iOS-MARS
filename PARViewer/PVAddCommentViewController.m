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
    if([self isIPhone5])
        _addCommentYOrigin = 98.0;
    else
        _addCommentYOrigin = 50.0;
        
    _commentTextView.font = [UIFont systemFontOfSize:18.0];
    [self addLines];
    
    _addCommentView.contentMode = UIViewContentModeScaleAspectFill;
    _addCommentView.clipsToBounds = YES;
    
    _addCommentView.layer.shadowOffset = CGSizeMake(0, 2.5);
    _addCommentView.layer.shadowRadius = 4;
    _addCommentView.layer.shadowOpacity = 0.7;
    _addCommentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    _addCommentView.layer.cornerRadius = 5;
    _addCommentView.layer.shadowPath = [self newPathForRoundedRect:_addCommentView.layer.bounds radius: 5];
    
    CAShapeLayer * l = [CAShapeLayer layer];
    // white top border
    [l setFrame: CGRectMake(-1, 0.2, _addCommentView.frame.size.width + 2, _addCommentView.frame.size.height + 2)];
    [l setBorderColor: [[UIColor colorWithWhite:1 alpha:1] CGColor]];
    [l setBorderWidth: 1];
    [l setCornerRadius: 5];
    [l setFillColor: nil];
    [_addCommentView.layer addSublayer: l];
    
    // black bottom border
    l = [CAShapeLayer layer];
    [l setFrame: CGRectMake(-1, -0.2, _addCommentView.frame.size.width + 2, _addCommentView.frame.size.height)];
    [l setBorderColor: [[UIColor colorWithWhite:0 alpha:0.5] CGColor]];
    [l setBorderWidth: 1];
    [l setCornerRadius: 5];
    [l setFillColor: nil];
    [_addCommentView.layer addSublayer: l];
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


- (void)slideIn{
//    [_commentTextView resignFirstResponder];
    _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, -_addCommentView.frame.size.height, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
    __weak UITextView *__commentTextView = _commentTextView;
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, _addCommentYOrigin, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
        [__commentTextView becomeFirstResponder];
    } completion:nil];
}

- (void)slideOut{
    __weak UITextView *__commentTextView = _commentTextView;
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionNone animations:^{
        _addCommentView.frame = CGRectMake(_addCommentView.frame.origin.x, -_addCommentView.frame.size.height, _addCommentView.frame.size.width, _addCommentView.frame.size.height);
        [__commentTextView resignFirstResponder];
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
    }];
}

- (IBAction)postButtonPressed:(id)sender{
    if([_commentTextView.text length] > 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:[defaults objectForKey:@"FBName"]forKey:@"userName"];
        [dict setObject:[defaults objectForKey:@"FBId"] forKey:@"userId"];
        [dict setObject:_commentTextView.text forKey:@"comment"];
        
        ARSiteComment *comment = [[ARSiteComment alloc] initWithDictionary:dict];
        __weak PVAddCommentViewController *__self = self;
        [_site addComment:comment withCallback:^(NSString *err){
            [__self slideOut];
            [__self.delegate postedCommentSuccessfully:__self];
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Enter a comment to post."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
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
    if ([text isEqualToString:@"\n"]) {
        [self performSelector:@selector(postButtonPressed:)];
    }
    return YES;
}

- (void)addLines{
//    CGFloat lineHeight = _commentTextView.frame.origin.y + 30.0;
//    while (lineHeight <= _commentTextView.frame.size.height + 22.0) {
//        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, lineHeight, _commentTextView.frame.size.width, 0.5)];
//        [line setBackgroundColor:[UIColor blackColor]];
//        [_addCommentView addSubview:line];
//        lineHeight = lineHeight + 22.0;
//    }
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, radius, radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

- (BOOL)isIPhone5{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    return delegate.window.frame.size.height == 568.0;
}

@end
