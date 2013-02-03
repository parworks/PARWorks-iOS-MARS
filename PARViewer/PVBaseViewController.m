//
//  PVBaseViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVBaseViewController.h"
#import "JSSlidingViewController.h"
#import "UINavigationItem+PVAdditions.h"


@implementation PVBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the button in the upper left that opens the sidebar
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_sidebar"] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_sidebar_highlighted"] forState:UIControlStateHighlighted];
    customButton.frame = CGRectMake(0, 0, 49, 46);
    [customButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setUnpaddedLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:customButton] animated:NO];
    [self.navigationItem setLeftJustifiedTitle: self.title];
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
