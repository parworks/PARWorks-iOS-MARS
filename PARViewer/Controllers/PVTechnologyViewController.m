//
//  PVSecondViewController.m
//  PARViewer
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

#import "PVTechnologyViewController.h"
#import "UIWebView+ScrollView.h"


@implementation PVTechnologyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Technology", @"Technology");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_technology"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self attachRightIntroButton];

    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"technology" ofType:@"html" inDirectory:@"HTML"];
    NSString * htmlFolder = [htmlPath stringByDeletingLastPathComponent];
    [_webView loadHTMLString:[NSString stringWithContentsOfFile:htmlPath encoding:NSASCIIStringEncoding error:nil] baseURL: [NSURL fileURLWithPath: htmlFolder]];
    [_webView.scrollView setDecelerationRate:1.0];
    [_webView removeShadows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
