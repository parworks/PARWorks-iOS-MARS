//
//  PVBaseViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBaseViewController.h"
#import "JSSlidingViewController.h"


@implementation PVBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the button in the upper left that opens the sidebar
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"navigationBar_menuButton_normal.png"] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"navigationBar_menuButton_highlighted.png"] forState:UIControlStateHighlighted];
    customButton.frame = CGRectMake(0, 0, 48, 30);
    [customButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
}

- (void)menuButtonPressed:(id)sender
{
    JSSlidingViewController * js = (JSSlidingViewController *)[self parentViewController];
    if ([js isKindOfClass: [JSSlidingViewController class]] == NO)
        js = (JSSlidingViewController *)[js parentViewController];
   
   if ([js isOpen])
       [js closeSlider:YES completion:nil];
   else
       [js openSlider:YES completion:nil];
}


@end
