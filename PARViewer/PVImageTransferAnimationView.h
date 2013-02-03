//
//  PVImageTransferAnimationView.h
//  GPUImage
//
//  Created by Ben Gotow on 2/3/13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVImageTransferAnimationView : UIView
{
    UIImage                     * _image;
    UIView                      * _hudView;
    UIView                      * _finalView;
    BOOL                          _finalViewReady;
    
    UIImageView                 * _shrinking;
    CALayer                     * _shrinkingMask;
    UIImageView                 * _scanline;
    BOOL                          _scanlineAnimationRunning;

    NSMutableArray              * _layers;
    CATextLayer                 * _loadingLayer;
}

- (void)startWithImage:(UIImage*)image andFinalView:(UIView*)finalView andHUDView:(UIView*)hudView;
- (void)finalViewReady;

- (BOOL)isRunning;

@end
