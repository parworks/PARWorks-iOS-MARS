//
//  PVSidebarViewController.m
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

#import "PVSidebarViewController.h"
#import "PVSidebarTableViewCell.h"
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
    [[_sidebarTableView layer] setCornerRadius: 5];
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
    PVSidebarTableViewCell * c = (PVSidebarTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"cell"];

    if (!c)
        c = [[PVSidebarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

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
