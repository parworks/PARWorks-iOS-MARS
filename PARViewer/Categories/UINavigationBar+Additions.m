//
//  UINavigationBar+Additions.m
//  PARViewer
//
//  Created by Grayson Sharpe on 2/6/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UINavigationBar+Additions.h"

@implementation UINavigationBar (Additions)

- (void)addShadowEffect
{
    [[self layer] setShadowRadius: 3];
    [[self layer] setShadowOffset: CGSizeMake(0, 1)];
    [[self layer] setShadowOpacity: 0.3];
}

@end
