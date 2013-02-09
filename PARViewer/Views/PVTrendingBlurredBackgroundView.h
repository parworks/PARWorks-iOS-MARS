 //
//  PVTrendingBlurredBackgroundView.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImagePicture.h"
#import "GPUImageView.h"

@protocol PVTrendingBlurredBackgroundViewDelegate <NSObject>
- (NSURL*)urlForSiteAtIndex:(int)ii;
@end

@interface PVTrendingBlurredBackgroundView : UIView
{
    CGRect            _imageViewRect;
    
    int               _baseIndex;
    GPUImageView    * _baseImageView;
    GPUImagePicture * _basePicture;
    
    int               _nextIndex;
    GPUImageView    * _nextImageView;
    GPUImagePicture * _nextPicture;
}

@property (nonatomic, assign) float floatingPointIndex;
@property (nonatomic, weak) NSObject<PVTrendingBlurredBackgroundViewDelegate>* delegate;

@end
