//
//  EPViewController.h
//  EasyPAR
//
//  Copyright 2012 PAR Works, Inc.
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
#import "GRCameraOverlayView.h"
#import "ARAugmentedView.h"
#import "PVImageTransferAnimationView.h"

@interface PVAugmentedPhotoViewController : UIViewController <UIAlertViewDelegate, ARAugmentedViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    GRCameraOverlayView             * _cameraOverlayView;
    
    UIImage                         * _image;
    
    UIImagePickerController         * _picker;
    BOOL                              _firstLoad;
    BOOL                              _selectedSite;

    PVImageTransferAnimationView    * _imageTransferAnimation;
    ARAugmentedPhoto                * _augmentedPhoto;
    __weak IBOutlet ARAugmentedView * _augmentedView;
    __weak IBOutlet UIView          * _toolbarContainer;
    __weak IBOutlet UIButton        * _cameraButton;
    __weak IBOutlet UIButton        * _libraryButton;
    __weak IBOutlet UIButton        * _settingButton;
}

@property (nonatomic, weak) ARSite * site;


#pragma mark - Lifecycle

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (NSUInteger)supportedInterfaceOrientations;

#pragma mark - Presentation

- (IBAction)exit:(id)sender;
- (IBAction)showCameraPicker:(id)sender;
- (IBAction)showLibraryPicker:(id)sender;
- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)source animated:(BOOL)animated;

#pragma mark - Animations

- (void)takePicture:(id)sender;

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)imageAugmented:(NSNotification*)notif;
- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay;

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
