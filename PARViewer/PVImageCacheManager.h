//
//  PVImageCacheManager.h
//  PARViewer
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

#import <Foundation/Foundation.h>

#define NOTIF_IMAGE_READY @"NOTIF_IMAGE_READY"

@interface PVImageCacheManager : NSObject
{
    NSCache * _imageCache;
    NSOperationQueue * _fetchQueue;
}
+ (PVImageCacheManager *)shared;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)init;

- (UIImage*)imageForURL:(NSURL*)url;

- (NSString*)diskCachePathFor:(NSURL*)url;
- (NSData*)diskCacheContentsFor:(NSURL*)url;
- (void)writeToDiskCache:(NSData*)data fromURL:(NSURL*)url;

- (UIImage*)blurredImageForURL:(NSURL*)url;

@end
