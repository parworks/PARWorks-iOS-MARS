//
//  PVScavengerHuntViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/11/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVScavengerHuntViewController.h"
#import "UIWebView+ScrollView.h"

@implementation PVScavengerHuntViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Scavenger Hunt", @"Scavenger Hunt");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_scavenger_hunt"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL signedIntoFacebook = NO;
    
    if (!signedIntoFacebook) {
        NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"scavenger_hunt" ofType:@"html" inDirectory:@"HTML"];
        NSString * htmlFolder = [htmlPath stringByDeletingLastPathComponent];
        [_webView loadHTMLString:[NSString stringWithContentsOfFile:htmlPath encoding:NSASCIIStringEncoding error:nil] baseURL: [NSURL fileURLWithPath: htmlFolder]];
    } else {
//        [_webView ]
    }
    
    [_webView.scrollView setDecelerationRate:1.0];
    [_webView removeShadows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"parworks-fb"]) {
        // login with facebook
        NSLog(@"Here");
        return NO;
    }
    return YES;
}

@end
