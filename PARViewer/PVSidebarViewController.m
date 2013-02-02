//
//  PVSidebarViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSidebarViewController.h"
#import "PVAppDelegate.h"

@implementation PVSidebarViewController

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
    
    // select the first item in the sidebar
    [_sidebarTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    return [delegate.contentControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITableViewCell * c = [tableView dequeueReusableCellWithIdentifier: @"cell"];

    if (!c)
        c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    // populate the cell with the image and title of the view controller
    UINavigationController * navController = [[delegate contentControllers] objectAtIndex: [indexPath row]];
    UIViewController * rootController = [[navController viewControllers] objectAtIndex: 0];
    [[c textLabel] setText: [rootController title]];
    [[c imageView] setImage: [rootController.tabBarItem image]];
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PVAppDelegate * delegate = (PVAppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate switchToController: [indexPath row]];
}
@end
