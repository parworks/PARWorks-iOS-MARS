//
//  EPViewController.m
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


#import <MobileCoreServices/MobileCoreServices.h>
#import "PVAugmentedPhotoViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+AnimationAdditions.h"
#import "CATextLayer+Loading.h"
#import "PARWorks.h"
#import "EPUtil.h"
#import "AdOverlayView.h"


#define CAMERA_TRANSFORM_SCALE 1.25


@implementation PVAugmentedPhotoViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _cameraButton.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _toolbarContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:_toolbarContainer.bounds].CGPath;
    
    if (_firstLoad) {
        _cameraOverlayView = [[GRCameraOverlayView alloc] initWithFrame:self.view.bounds];
        [_cameraOverlayView.augmentButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];

        _imageTransferAnimation = [[PVImageTransferAnimationView alloc] initWithFrame: self.view.bounds];
        [self.view addSubview: _imageTransferAnimation];

        [self showCameraPicker:nil];
        _firstLoad = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - Presentation

- (IBAction)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showCameraPicker:(id)sender
{
    [self showPickerWithSourceType:UIImagePickerControllerSourceTypeCamera animated:YES];
}

- (IBAction)showLibraryPicker:(id)sender
{
    [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary animated:YES];
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)source animated:(BOOL)animated
{
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    
    if (source == UIImagePickerControllerSourceTypeCamera &&
        [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.mediaTypes = @[(NSString *) kUTTypeImage];
        _picker.cameraOverlayView = _cameraOverlayView;
        _picker.showsCameraControls = NO;
        _picker.cameraViewTransform = CGAffineTransformMakeScale(CAMERA_TRANSFORM_SCALE, CAMERA_TRANSFORM_SCALE);
        _picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    } else if (source == UIImagePickerControllerSourceTypePhotoLibrary) {
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:_picker animated:animated completion:nil];
}

- (void)takePicture:(id)sender
{
    [_picker takePicture];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize viewportSize = self.view.bounds.size;
    CGSize originalSize = [originalImage size];
    
    UIGraphicsBeginImageContextWithOptions(viewportSize, YES, 1);
    
    float scale = fminf(viewportSize.width / originalSize.width, viewportSize.height / originalSize.height) * CAMERA_TRANSFORM_SCALE;
    CGSize resizedSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    CGRect resizedFrame = CGRectMake((viewportSize.width - resizedSize.width) / 2, (viewportSize.height - resizedSize.height) / 2 - 20, resizedSize.width, resizedSize.height);
    [originalImage drawInRect:resizedFrame];

    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    [_imageTransferAnimation startWithImage: _image andFinalView:_augmentedView andHUDView:_toolbarContainer];
    
    // Upload the original image to the AR API for processing. We'll animate the
    // resized image back on screen once it's finished.
    _augmentedPhoto = [_site augmentImage: originalImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageAugmented:) name:NOTIF_AUGMENTED_PHOTO_UPDATED object:_augmentedPhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageAugmented:(NSNotification*)notif
{
    if (_augmentedPhoto.response == BackendResponseFinished) {
        if ([[_augmentedPhoto overlays] count] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"We weren't able to find any overlays in that image. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self showCameraPicker:nil];
            return;
        }
        
        [self.view bringSubviewToFront: _augmentedView];
        _augmentedView.transform = CGAffineTransformIdentity;
        [_augmentedView setAugmentedPhoto: _augmentedPhoto];
        _augmentedView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        _augmentedView.delegate = self;
        
        [_imageTransferAnimation finalViewReady];

    } else if (_augmentedPhoto.response == BackendResponseFailed){
        [[[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"The PAR Works API server did not successfully augment the photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self showCameraPicker:nil];

    } else {
        // just wait...
    }
}



- (AROverlayView *)overlayViewForOverlay:(AROverlay *)overlay
{
    if ([overlay.name isEqualToString: @"Ad"]) {
        AdOverlayView * v = [[AdOverlayView alloc] initWithFrame:CGRectMake(0, 0, 560*0.6, 320*0.6) points:overlay.points andMedia:@"ad" ofType:@"png" withWebTarget:nil];
        return v;
    } else {
        AdOverlayView * v = [[AdOverlayView alloc] initWithFrame:CGRectMake(0, 0, _augmentedView.frame.size.width / CAMERA_TRANSFORM_SCALE - 40, _augmentedView.frame.size.height / CAMERA_TRANSFORM_SCALE - 40) points:overlay.points andMedia:overlay.name ofType:@"png" withWebTarget: [NSURL URLWithString: overlay.content]];
        return v;
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://parworks.com/"]];
}

@end