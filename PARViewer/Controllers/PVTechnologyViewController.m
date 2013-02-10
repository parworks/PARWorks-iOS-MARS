//
//  PVSecondViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVTechnologyViewController.h"
#import "UIWebView+ScrollView.h"

@interface PVTechnologyViewController ()

@end

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


@end
