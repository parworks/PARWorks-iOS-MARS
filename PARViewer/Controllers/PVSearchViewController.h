//
//  PVSearchViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARAugmentedPhotoSource.h"
#import "PVBaseViewController.h"


@interface PVSearchViewController : PVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSObject<ARAugmentedPhotoSource>* _augmentedPhotoSource;
    ARAugmentedPhoto *_curAugmentedPhoto;
}

@property (weak, nonatomic) IBOutlet UITextField * searchTextField;
@property (strong, nonatomic) NSArray * searchResultSites;
@property (weak, nonatomic) IBOutlet UITableView * searchResultsTableView;

@property (weak, nonatomic) IBOutlet UITableView * filteredTagsTableView;
@property (strong, nonatomic) NSMutableArray * filteredTags;

@property (strong, nonatomic) IBOutlet UIView *labelsContainer;
@property (weak, nonatomic) IBOutlet UILabel *popularSearchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIControl *dimView;

@end
