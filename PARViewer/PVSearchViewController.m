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
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
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

- (void)hidePopularSitesAndSearch
{
    if ([_popularSitesTableView alpha] == 0)
        return;
    
    [_searchTextField resignFirstResponder];
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
    
    [_searchTextField resignFirstResponder];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.2];
    CGRect tableViewFrame = [_popularSitesTableView frame];
    tableViewFrame.origin.y -= 15;
    [_popularSitesTableView setFrame: tableViewFrame];
    [_popularSitesTableView setAlpha: 1];
    [UIView commitAnimations];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ARManager shared] featuredTags] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVFeaturedTagCell * c = (PVFeaturedTagCell*)[tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (!c){
        c = [[PVFeaturedTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString * tag = [[[ARManager shared] featuredTags] objectAtIndex: [indexPath row]];
    [[c textLabel] setText: tag];
    [c setIsFirstRow: ([indexPath row] == 0)];
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString * tag = [[[ARManager shared] featuredTags] objectAtIndex: [indexPath row]];
    [_searchTextField setText: tag];
    [self hidePopularSitesAndSearch];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hidePopularSitesAndSearch];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] == 0) {
        [self showPopularSites];
    }
    return YES;
}

@end
