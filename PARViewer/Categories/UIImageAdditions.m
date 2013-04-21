//
//  UIImageAdditions.m
//  PARViewer
//
//  The UIImageAdditions add convenience functions to the UIImage class that allow it to be
//  scaled and serialized.
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

#import "UIImageAdditions.h"

@implementation UIImage (ScribbleChatAdditions)

- (UIImage*)scaledImage:(float)scale
{
    CGImageRef image = [self CGImage];
    CGSize newSize = CGSizeMake(self.size.width * scale, self.size.height * scale);
    UIGraphicsBeginImageContext(newSize);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, newSize.height);
    CGContextScaleCTM(c, 1, -1);
    CGContextDrawImage(c, CGRectMake(0, 0, newSize.width, newSize.height), image);
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
