//
//  PVSearchViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSearchViewController.h"
#import "JSSlidingViewController.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"
#import "PVFeaturedTagCell.h"
#import "PVSiteDetailViewController.h"
#import "PVSiteTableViewCell.h"

@implementation PVSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_search"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard) name:JSSlidingViewControllerWillOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSuggestions) name:NOTIF_TAGS_UPDATED object:nil];
    
        [[ARManager shared] fetchTags];
    }
    return self;
}

- (void)dismissKeyboard
{
    [_searchTextField resignFirstResponder];
}

- (void)viewDidLoad
{
    // Prepare to animate in the popular sites
    CGRect tableViewFrame = [_popularSitesTableView frame];
    tableViewFrame.origin.y += 15;
    [_popularSitesTableView setFrame: tableViewFrame];
    [_popularSitesTableView setAlpha: 0];
    [_searchResultsTableView setAlpha: 0];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_searchResultSites)
        [self showPopularSites];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshSuggestions
{
    [_popularSitesTableView reloadData];
}

- (void)hidePopularSites
{
    if ([_popularSitesTableView alpha] == 0)
        return;
    
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.2];
    CGRect tableViewFrame = [_popularSitesTableView frame];
    tableViewFrame.origin.y += 15;
    [_popularSitesTableView setFrame: tableViewFrame];
    [_popularSitesTableView setAlpha: 0];
    [UIView commitAnimations];
}

- (void)showPopularSites
{
    if ([_popularSitesTableView alpha] == 1)
        return;
    
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.2];
    [_searchResultsTableView setAlpha: 0];
    [UIView commitAnimations];

    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.3];
    CGRect tableViewFrame = [_popularSitesTableView frame];
    tableViewFrame.origin.y -= 15;
    [_popularSitesTableView setFrame: tableViewFrame];
    [_popularSitesTableView setAlpha: 1];
    [UIView commitAnimations];
}

- (void)performSearch
{
    NSString * tagName = [_searchTextField text];
    [[ARManager shared] fetchTagResults:tagName withCallback:^(NSString *tagName, NSArray *sites) {
        if (![tagName isEqualToString: [_searchTextField text]])
            return;
        
        self.searchResultSites = sites;
        [_searchResultsTableView reloadData];
        
        if ([_searchResultsTableView alpha] == 0) {
            [UIView beginAnimations:nil context: nil];
            [UIView setAnimationDuration: 0.2];
            [_searchResultsTableView setAlpha: 1];
            [UIView commitAnimations];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _popularSitesTableView)
        return [[[ARManager shared] featuredTags] count];
    else
        return [_searchResultSites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _popularSitesTableView) {
        PVFeaturedTagCell * c = (PVFeaturedTagCell*)[tableView dequeueReusableCellWithIdentifier: @"cell"];
        if (!c){
            c = [[PVFeaturedTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        NSString * tag = [[[ARManager shared] featuredTags] objectAtIndex: [indexPath row]];
        [[c textLabel] setText: tag];
        [c setIsFirstRow: ([indexPath row] == 0)];
        return c;

    } else {
        PVSiteTableViewCell * c = (PVSiteTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"siteCell"];
        if (!c)
            c = [[PVSiteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"siteCell"];
        ARSite * site = [_searchResultSites objectAtIndex: [indexPath row]];
        [c setSite: site];
        return c;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == _popularSitesTableView) {
        NSString * tag = [[[ARManager shared] featuredTags] objectAtIndex: [indexPath row]];
        [_searchTextField setText: tag];
        [_searchTextField resignFirstResponder];
        [self hidePopularSites];
        [self performSearch];
    
    } else {
        ARSite * site = [_searchResultSites objectAtIndex: [indexPath row]];
        PVSiteDetailViewController * siteDetailController = [[PVSiteDetailViewController alloc] initWithSite: site];
        [self presentViewController:siteDetailController animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([[textField text] length] > 0) {
        [self hidePopularSites];
        [self performSearch];
    } else
        [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self showPopularSites];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] == 0) {
        [self showPopularSites];
    } else {
        [self hidePopularSites];
    }
    return YES;
}

@end
