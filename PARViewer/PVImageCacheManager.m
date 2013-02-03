//
//  PVImageCacheManager.m
//  PARViewer
//
//  Created by Ben Gotow on 1/31/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "PVImageCacheManager.h"
#import "AFImageRequestOperation.h"

static PVImageCacheManager * sharedImageCacheManager;

@implementation PVImageCacheManager


#pragma mark -
#pragma mark Singleton Implementation

+ (PVImageCacheManager *)shared
{
	@synchronized(self)
	{
		if (sharedImageCacheManager == nil)
			sharedImageCacheManager = [[self alloc] init];
	}
	return sharedImageCacheManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (sharedImageCacheManager == nil) {
			sharedImageCacheManager = [super allocWithZone:zone];
			return sharedImageCacheManager;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)init
{
	self = [super init];
    
	if (self) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setCountLimit: 20];
        _fetchQueue = [[NSOperationQueue alloc] init];
        [_fetchQueue setMaxConcurrentOperationCount: 4];
    }
	return self;
}

- (UIImage*)imageForURL:(NSURL*)url
{
    if (!url) {
        return nil;

    } else if ([_imageCache objectForKey: url]) {
        return [_imageCache objectForKey: url];

    } else {
        NSURLRequest * req = [NSURLRequest requestWithURL: url];
        
        // make sure there's not an open request for this image already
        for (AFImageRequestOperation * op in [_fetchQueue operations])
            if ([[[op request] URL] isEqual: url])
                return nil;
        
        AFImageRequestOperation * op = [AFImageRequestOperation imageRequestOperationWithRequest:req success:^(UIImage *image) {
            [_imageCache setObject: image forKey: url];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_IMAGE_READY object:url];
        }];
        [_fetchQueue addOperation: op];

        return nil;
    }
}

@end
