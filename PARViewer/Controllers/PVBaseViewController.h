//
//  PVBaseViewController.h
//  PARViewer
//
//  Created by Ben Gotow on 2/2/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVSlidingViewController.h"

@interface PVBaseViewController : UIViewController

- (void)attachRightIntroButton;
- (PVSlidingViewController*)parentSlidingViewController;

@end
