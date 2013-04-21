//
//  UIImageView+AnimationAdditions.m
//  Graffiti
//
//  Copyright 2012 PAR Works, Inc.
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

#import "UIImageView+AnimationAdditions.h"
#import "UIViewAdditions.h"

@implementation UIImageView (AnimationAdditions)

- (id)initWithImageSeries:(NSString*)fileFormatString
{
    self = [super init];
    if (self) {
        NSMutableArray * b = [NSMutableArray array];
        UIImage * img;
        
        for (int ii = 1; ii < 100; ii++) {
            img = [UIImage imageNamed:[NSString stringWithFormat: fileFormatString, ii]];
            if (img == nil)
                break;
            else {
                [self setFrameSize:[img size]];
                [b addObject: img];
            }
        }
        [self setAnimationImages: b];
        [self setAnimationDuration: 0.4];
        [self setAnimationRepeatCount: 1];
        [self setImage: [b lastObject]];
    }
    return self;
}

@end
