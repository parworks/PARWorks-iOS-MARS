//
//  UIFont+ThemeAdditions.m
//  PARViewer
//
//  Created by Ben Gotow on 2/5/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "UIFont+ThemeAdditions.h"

@implementation UIFont (ThemeAdditions)

+ (UIFont*)boldParworksFontWithSize:(float)size
{
    return [UIFont fontWithName:@"HiraKakuProN-W6" size:size];
}

+ (UIFont*)parworksFontWithSize:(float)size
{
    return [UIFont fontWithName:@"HiraKakuProN-W3" size:size];
}

@end
