//
//  PVBaseViewController.m
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
#import "UINavigationItem+PVAdditions.h"


@implementation PVBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self attachLeftSidebarButton];
    [self.navigationItem setLeftJustifiedTitle: self.title];
}

- (PVSlidingViewController*)parentSlidingViewController
{
    PVSlidingViewController * js = (PVSlidingViewController *)[self parentViewController];
    if ([js isKindOfClass: [PVSlidingViewController class]] == NO)
        js = (PVSlidingViewController *)[js parentViewController];
    return js;
}

- (void)attachLeftSidebarButton
{
    // Add the button in the upper left that opens the sidebar
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_sidebar"] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"bar_item_sidebar_highlighted"] forState:UIControlStateHighlighted];
    customButton.frame = CGRectMake(0, 0, 57, 46);
    [customButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setUnpaddedLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:customButton] animated:NO];
}

- (void)attachRightIntroButton
{
    UIButton * backToIntroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToIntroButton setBackgroundImage:[UIImage imageNamed:@"bar_item_intro"] forState:UIControlStateNormal];
    [backToIntroButton setBackgroundImage:[UIImage imageNamed:@"bar_item_intro_highlighted"] forState:UIControlStateHighlighted];
    backToIntroButton.frame = CGRectMake(0, 0, 57, 46);
    [backToIntroButton addTarget:self action:@selector(introBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backToIntro = [[UIBarButtonItem alloc] initWithCustomView: backToIntroButton];
    [self.navigationItem setUnpaddedRightBarButtonItem:backToIntro animated: NO];
}

- (void)menuButtonPressed:(id)sender
{
    PVSlidingViewController * js = [self parentSlidingViewController];
   if ([js isOpen])
       [js closeSlider:YES completion:nil];
   else
       [js openSlider:YES completion:nil];
}

- (void)introBarButtonPressed:(id)sender
{
    [[self parentSlidingViewController] showIntroControllerAnimated:YES];
}


@end
