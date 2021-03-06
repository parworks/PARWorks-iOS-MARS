//
//  EPUtil.h
//  EasyPAR
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


#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (int)smallImagesWithWidth:(int)width height:(int)height fromImage:(UIImage *)image withImageReadyCallback:(void (^)(int i, UIImage* img))imgCallback;
+ (int)arrayIndexForCols:(int)cols rowIndex:(int)r columnIndex:(int)c;
+ (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius;

+ (id)blurredImageWithImage:(UIImage *)img;

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, UIColor *color);


@end
