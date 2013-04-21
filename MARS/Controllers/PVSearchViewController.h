//
//  PVSearchViewController.h
//  MARS
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
