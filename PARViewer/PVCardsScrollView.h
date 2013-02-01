//
//  PVCardsScrollView.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PVCardsScrollViewDelegate <NSObject>

- (UIView*)

@end
@interface PVCardsScrollView : UIScrollView

@property (weak, nonatomic) NSObject<PVCardsScrollViewDelegate>* delegate;
@end
