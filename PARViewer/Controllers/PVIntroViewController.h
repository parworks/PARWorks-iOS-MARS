//
//  PVIntroViewController.h
//  PARViewer
//
//  Created by Demetri Miller on 2/15/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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
