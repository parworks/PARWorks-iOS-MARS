//
//  UIView+ImageCapture.m
//  CameraTransitionTest
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+ImageCapture.h"


@implementation UIView (ImageCapture)

- (UIImage*)imageRepresentationAtScale:(float)outputScaleFactor
{
    CGRect b = [self bounds];
    float contentScaleFactor = [self contentScaleFactor];
    
    if ((b.size.width == 0) || (b.size.height == 0))
        return nil;
    
    b.size.width = b.size.width * contentScaleFactor * outputScaleFactor;
    b.size.height = b.size.height * contentScaleFactor * outputScaleFactor;
    
    UIGraphicsBeginImageContext(b.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(c, outputScaleFactor * contentScaleFactor, outputScaleFactor * contentScaleFactor);
    if ([self isKindOfClass:[UIScrollView class]]) {
        CGContextTranslateCTM(c, -[(UIScrollView*)self contentOffset].x, -[(UIScrollView*)self contentOffset].y);
    }
    [[self layer] renderInContext: c];
    UIImage * i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return i;
}



@end
