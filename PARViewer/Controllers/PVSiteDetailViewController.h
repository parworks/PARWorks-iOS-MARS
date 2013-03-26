//
//  PVSiteDetailViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 1/29/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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
