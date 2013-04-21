//
//  PVSearchViewController.m
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

#import "PVSearchViewController.h"
#import "JSSlidingViewController.h"
#import "ARAugmentedPhoto.h"
#import "ARManager.h"
#import "ARManager+MARS_Extensions.h"
#import "ARMultiSite.h"
#import "PVBorderedWhiteCell.h"
#import "PVSiteDetailViewController.h"
#import "PVSiteTableViewCell.h"
#import "UIViewController+Transitions.h"
#import "UIViewAdditions.h"
#import "UIView+ImageCapture.h"

typedef enum {
    FilteredTagsTableState_NoResults = 0,
    FilteredTagsTableState_Results,
    FilteredTagsTableState_Popular,
} FilteredTagsTableState;


@implementation PVSearchViewController
{
    FilteredTagsTableState _filteredTagTableState;
    GRCameraOverlayView *_cameraOverlayView;
}


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
    _filteredTagTableState = -1;
    
    // Prepare to animate in the popular sites
    CGRect tableViewFrame = [_filteredTagsTableView frame];
    tableViewFrame.origin.y += 15;
    [_filteredTagsTableView setFrame: tableViewFrame];
    [_filteredTagsTableView setAlpha: 0];
    [_searchResultsTableView setAlpha: 0];
    [_dimView setAlpha: 0];
    [_dimView addTarget:self action:@selector(dimViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_noResultsLabel setAlpha: 0];
    [self.view bringSubviewToFront:_dimView];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_labelsContainer.superview) {
        [_labelsContainer setFrameY:-(_labelsContainer.frame.size.height)];
        [self updateFilteredTableViewForState:FilteredTagsTableState_Popular];
        [_filteredTagsTableView addSubview:_labelsContainer];
    }
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
    NSString * query = [[_searchTextField text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    FilteredTagsTableState state;
    if ([query length] == 0) {
        self.filteredTags = [NSMutableArray arrayWithArray: [[ARManager shared] featuredTags]];
        state = FilteredTagsTableState_Popular;
    } else {
        self.filteredTags = [NSMutableArray array];
        for (NSString * tag in [[ARManager shared] availableTags]) {
            if ([tag rangeOfString: query options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_filteredTags addObject: tag];
            }
        }
        
        if (_filteredTags.count > 0) {
            state = FilteredTagsTableState_Results;
        } else {
            state = FilteredTagsTableState_NoResults;
            self.filteredTags = [NSMutableArray arrayWithArray: [[ARManager shared] featuredTags]];
        }
    }
    
    [self updateFilteredTableViewForState:state];
    [_filteredTagsTableView reloadData];
}

- (void)hidePopularSites
{
    if ([_filteredTagsTableView alpha] == 0)
        return;
    
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.2];
    CGRect tableViewFrame = [_filteredTagsTableView frame];
    tableViewFrame.origin.y += 15;
    [_filteredTagsTableView setFrame: tableViewFrame];
    [_filteredTagsTableView setAlpha: 0];
    [UIView commitAnimations];
}

- (void)showPopularSites
{
    [self refreshSuggestions];
    
    if ([_filteredTagsTableView alpha] == 1)
        return;
    
    
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.2];
    [_searchResultsTableView setAlpha: 0];
    [UIView commitAnimations];

    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationDuration: 0.3];
    CGRect tableViewFrame = [_filteredTagsTableView frame];
    tableViewFrame.origin.y -= 15;
    [_filteredTagsTableView setFrame: tableViewFrame];
    [_filteredTagsTableView setAlpha: 1];
    [UIView commitAnimations];
}

- (void)performSearch
{
    NSString * tagName = [[_searchTextField text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    [[ARManager shared] fetchTagResults:tagName withCallback:^(NSString *tagName, NSArray *sites) {
        NSString * currentTagName = [[_searchTextField text] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        if (![tagName isEqualToString: currentTagName])
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


#pragma mark - FilteredTagsTableView Helper
- (void)updateFilteredTableViewForState:(FilteredTagsTableState)state
{
    if (state == _filteredTagTableState) {
        return;
    }
    
    _filteredTagTableState = state;
    switch (state) {
        case FilteredTagsTableState_NoResults:
            _noResultsLabel.alpha = 1.0;
            _popularSearchesLabel.alpha = 1.0;
            _filteredTagsTableView.contentInset = UIEdgeInsetsMake(_labelsContainer.frame.size.height, 0, 0, 0);
            [_filteredTagsTableView setContentOffset:CGPointMake(0, -_labelsContainer.frame.size.height) animated:NO];
            break;
        case FilteredTagsTableState_Results:
            _noResultsLabel.alpha = 0.0;
            _popularSearchesLabel.alpha = 0.0;
            _filteredTagsTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
            [_filteredTagsTableView setContentOffset:CGPointMake(0, -10) animated:NO];
            break;
        case FilteredTagsTableState_Popular:
            _noResultsLabel.alpha = 0.0;
            _popularSearchesLabel.alpha = 1.0;
            _filteredTagsTableView.contentInset = UIEdgeInsetsMake(_popularSearchesLabel.frame.size.height+15, 0, 0, 0);
            [_filteredTagsTableView setContentOffset:CGPointMake(0, -_popularSearchesLabel.frame.size.height-15) animated:NO];
            break;
            
        default:
            break;
    }
}


#pragma mark - DimView
- (void)dimViewTapped:(id)sender
{
    [_searchTextField resignFirstResponder];
}

- (void)setDimViewAlpha:(CGFloat)alpha animated:(BOOL)animated
{
    CGFloat duration = animated ? 0.2 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        _dimView.alpha = alpha;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchTextField resignFirstResponder];
}


#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _filteredTagsTableView)
        return [_filteredTags count];
    else
        return [_searchResultSites count] + 1;  // +1 for "augment all" option
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _filteredTagsTableView) {
        PVBorderedWhiteCell * c = (PVBorderedWhiteCell*)[tableView dequeueReusableCellWithIdentifier: @"cell"];
        if (!c){
            c = [[PVBorderedWhiteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        NSString * tag = [_filteredTags objectAtIndex: [indexPath row]];
        [[c textLabel] setText: tag];
        [c setIsFirstRow: ([indexPath row] == 0)];
        return c;

    } else {
        PVSiteTableViewCell * c = (PVSiteTableViewCell*)[tableView dequeueReusableCellWithIdentifier: @"siteCell"];
        if (!c) {
            c = [[PVSiteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"siteCell"];
        }
        
        if (indexPath.row == 0) {
            [c setSite: nil];
            c.textLabel.text = @"Augment Site List";
            
        } else {
            ARSite * site = [_searchResultSites objectAtIndex: [indexPath row] - 1];
            [c setSite: site];
        }
        
        return c;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == _filteredTagsTableView) {
        NSString * tag = [_filteredTags objectAtIndex: [indexPath row]];
        [_searchTextField setText: tag];
        [_searchTextField resignFirstResponder];
        [self hidePopularSites];
        [self performSearch];
    } else {
        if (indexPath.row == 0) {
            // TOOD: Augment all sites here.
            
            
        } else {
            ARSite * site = [_searchResultSites objectAtIndex: [indexPath row] - 1];
            PVSiteDetailViewController * siteDetailController = [[PVSiteDetailViewController alloc] initWithSite: site];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:siteDetailController] animated:YES completion:NULL];            
        }
    }
}

- (void)showCameraPickerWithSiteIDs:(NSArray *)ids
{
    if (ids == nil || ids.count == 0)
        return;
    
    UIImage * screenCap = [self.view imageRepresentationAtScale: 1.0];
    UIImage * depthImage = [UIImage imageNamed:@"unfold_depth_image.png"];
    self.view.hidden = YES;
    
    _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
    _augmentedPhotoSource = [[ARMultiSite alloc] initWithSiteIdentifiers: ids];
    _cameraOverlayView.site = _augmentedPhotoSource;
    _cameraOverlayView.delegate = self;
    
    UIImagePickerController *picker = [GRCameraOverlayView defaultImagePicker];
    picker.delegate = _cameraOverlayView;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        picker.cameraOverlayView = _cameraOverlayView;
        _cameraOverlayView.imagePicker = picker;
    }
    
    UIImage * background = nil;
    if (self.view.frame.size.height < 500)
        background = [UIImage imageNamed:@"camera_iris.png"];
    else
        background = [UIImage imageNamed:@"camera_iris_568h.png"];
    
    [self peelPresentViewController:picker withBackgroundImage:background andContentImage:screenCap depthImage:depthImage];

}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setDimViewAlpha:1.0 animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setDimViewAlpha:0.0 animated:YES];
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
    [self performSelectorOnMainThread:@selector(showPopularSites) withObject:nil waitUntilDone:NO];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] == 0) {
        [self performSelectorOnMainThread:@selector(showPopularSites) withObject:nil waitUntilDone:NO];
        [self setDimViewAlpha:1.0 animated:YES];
    } else {
        if (_searchResultsTableView.alpha > 0) {
            [self showPopularSites];
        }
        [self performSelectorOnMainThread:@selector(refreshSuggestions) withObject:nil waitUntilDone:NO];
        [self setDimViewAlpha:0.0 animated:YES];
    }
    
    return YES;
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
