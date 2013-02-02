//
//  PVSiteDetailViewController.m
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVSiteDetailViewController.h"
#import "ARSite+MARS_Extensions.h"
#import "UIImageView+AFNetworking.h"

@interface PVSiteDetailViewController ()

@end

@implementation PVSiteDetailViewController

- (id)initWithSite:(ARSite *)site
{
    self = [super init];
    if (self) {
        self.site = site;        
        
//        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:@"Grayson" forKey:@"userName"];
//        [dict setObject:@"667325981268" forKey:@"userId"];
//        [dict setObject:@"test comment" forKey:@"comment"];
//        
//        ARSiteComment *comment = [[ARSiteComment alloc] initWithDictionary:dict];
//        
//        [_site addComment:comment withCallback:^(NSString *err){
//            // start refreshing the site comments
//            [site fetchComments];
//        }];
        
        [site fetchComments];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self update];
    
    // register to receive updates about the site in the future
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_UPDATED object: self.site];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NOTIF_SITE_COMMENTS_UPDATED object: self.site];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
            
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIImage imageNamed:@"posterImage.png"].size.height)];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerImageView.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0];
//    [_headerImageView setImageWithURL:[NSURL URLWithString:_site.posterImageURL] placeholderImage:[UIImage imageNamed:@"posterImage.png"]];
    [_headerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/hd4ar-dev-us-east-1/physical_models/FirstSite/registrations/940a4f72-8d72-4b56-a4b2-8a639b679f76.jpg"]]
                            placeholderImage:[UIImage imageNamed:@"posterImage.png"]
                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                         NSLog(@"%@", response);
                                     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                         NSLog(@"%@", response);                                         
                                     }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
    [headerView setBackgroundColor:[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0]];
    
    self.parallaxView = [[PVParallaxTableView alloc] initWithBackgroundView:_headerImageView
                                                                foregroundTableView:_tableView];
    _parallaxView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _parallaxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _parallaxView.backgroundHeight = 150.0f;
    _parallaxView.tableViewDelegate = self;
    [_parallaxView setTableHeaderView:headerView];
    [self.view addSubview:_parallaxView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)update
{
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)myTableView numberOfRowsInSection:(NSInteger)section {
    return [_site.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];    
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    cell.textLabel.text = comment.body;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ARSiteComment *comment = (ARSiteComment*)[_site.comments objectAtIndex:indexPath.row];
    NSLog(@"%@", [comment description]);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 44.0;
}




@end
