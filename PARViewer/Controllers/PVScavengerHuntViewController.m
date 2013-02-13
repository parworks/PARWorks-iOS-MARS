//
//  PVScavengerHuntViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/11/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVScavengerHuntViewController.h"
#import "UIWebView+ScrollView.h"
#import "PVAppDelegate.h"

@implementation PVScavengerHuntViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Scavenger Hunt", @"Scavenger Hunt");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_scavenger_hunt"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFacebookNotification:) name:NOTIF_FACEBOOK_INFO_REQUEST object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFacebookNotification:) name:NOTIF_FACEBOOK_LOGGED_IN object: nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self loadWebView];
    [_webView.scrollView setDecelerationRate:1.0];
    [_webView removeShadows];
}

- (void)loadWebView{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (![delegate isSignedIntoFacebook]) {
        NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"scavenger_hunt" ofType:@"html" inDirectory:@"HTML"];
        NSString * htmlFolder = [htmlPath stringByDeletingLastPathComponent];
        [_webView loadHTMLString:[NSString stringWithContentsOfFile:htmlPath encoding:NSASCIIStringEncoding error:nil] baseURL: [NSURL fileURLWithPath: htmlFolder]];
    } else {
        NSString *html = [NSString stringWithFormat:@"<html><body><p>Facebook is signed in. Let's scavenge!</p></body></html>"];
        [_webView loadHTMLString:html baseURL:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"parworks-fb"]) {
        // login with facebook
        PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate authorizeFacebook:YES];
        return NO;
    }
    return YES;
}

- (void)receivedFacebookNotification:(NSNotification *)notification {
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_INFO_REQUEST]){
        [delegate showHUD:@"Gathering Info..."];
    }
    if([[notification name] isEqualToString:NOTIF_FACEBOOK_LOGGED_IN] && [[notification object] isEqualToString:@"YES"]){
        [delegate hideHUD];
        [self loadWebView];
    }
}


@end
