//
//  PVLoadingView.h
//  LoadingView
//
//  Created by Ben Gotow on 2/13/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PVLoadingView : UIView
{
    UIView * _block1;
    UIView * _block2;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
