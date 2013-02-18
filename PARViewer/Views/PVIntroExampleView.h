//
//  PVIntroExampleView.h
//  PARViewer
//
//  Created by Demetri Miller on 2/17/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PVIntroExampleView : UIControl
{
    UIView *_dimView;
}

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UILabel *label;

+ (id)viewFromNIB;

@end
