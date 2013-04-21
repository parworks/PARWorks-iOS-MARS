//
//  PVSiteDetailViewController.h
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

#import "ARSite.h"
#import "PVParallaxTableView.h"
#import "PVAddCommentViewController.h"
#import "GPUImageView.h"
#import "GRCameraOverlayView.h"
#import "ARAugmentedView.h"
#import <MapKit/MapKit.h>
#import "PSTCollectionView.h"
#import "PVCommentTableViewCell.h"

@interface PVSiteDetailViewController : UIViewController <GRCameraOverlayViewDelegate, PSUICollectionViewDataSource, PSUICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, PVAddCommentViewControllerDelegate, PVCommentTableViewCellDelegate, MKMapViewDelegate>
{
    PVAddCommentViewController  *_addCommentViewController;
    GPUImageView                * _bgCopyImageView;
    GRCameraOverlayView         * _cameraOverlayView;
}

@property (nonatomic, strong) ARSite * site;

@property (nonatomic, weak) IBOutlet ARAugmentedView *headerImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;

@property (nonatomic, strong) PVParallaxTableView *parallaxView;
@property (nonatomic, strong) UIView * takePhotoContainer;
@property (nonatomic, strong) UIButton * takePhotoButton;

//Map Container Outlets
@property (nonatomic, weak) IBOutlet UIView *detailsMapView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIButton *mapShadowButton;
@property (nonatomic, weak) IBOutlet UILabel *identifierLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;

//PhotoScrollView Container Outlets
@property (nonatomic, weak) IBOutlet UIView *detailsPhotoScrollView;
@property (nonatomic, weak) IBOutlet UILabel *photoCountLabel;
@property (nonatomic, weak) IBOutlet PSUICollectionView *collectionView;

- (id)initWithSite:(ARSite *)site;
- (IBAction)addCommentButtonPressed:(id)sender;

- (IBAction)mapViewPressed:(id)sender;

@end
