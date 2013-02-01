//
//  PVImageCacheManager.h
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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

@end
