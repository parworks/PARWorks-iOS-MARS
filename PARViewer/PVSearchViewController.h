//
//  PVSearchViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/26/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVBaseViewController.h"

@interface PVSearchViewController : PVBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    ;
}

@property (weak, nonatomic) IBOutlet UITextField * searchTextField;
@property (strong, nonatomic) IBOutlet NSArray * searchResultSites;
@property (weak, nonatomic) IBOutlet UITableView * searchResultsTableView;
@property (weak, nonatomic) IBOutlet UITableView * popularSitesTableView;

@end
