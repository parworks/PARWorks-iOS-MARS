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
    UIImageView     * _baseImageView;
    
    int               _nextIndex;
    UIImageView     * _nextImageView;
}

@property (nonatomic, assign) float floatingPointIndex;
@property (nonatomic, weak) NSObject<PVTrendingBlurredBackgroundViewDelegate>* delegate;

@end
