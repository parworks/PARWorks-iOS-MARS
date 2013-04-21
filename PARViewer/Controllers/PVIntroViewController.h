//
//  PVIntroViewController.h
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

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "GPUImageView.h"
#import "GRCameraOverlayView.h"

@interface PVIntroViewController : UIViewController <PSUICollectionViewDataSource, PSUICollectionViewDelegate, GRCameraOverlayViewDelegate>
{
    NSTimer             * _hintTimer;
    GPUImageView        * _bgCopyImageView;
    GRCameraOverlayView * _cameraOverlayView;
    
    ARSite              * _currentExampleSite;

}
@property(nonatomic, weak) IBOutlet PSUICollectionView *collectionView;
@property(nonatomic, weak) IBOutlet UIPageControl *pageControl;

@end
