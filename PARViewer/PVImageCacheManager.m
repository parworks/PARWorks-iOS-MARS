//
//  PVImageCacheManager.m
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

#import "PVImageCacheManager.h"
#import "AFImageRequestOperation.h"
#import "PVTrendingBlurredBackgroundView.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageBrightnessFilter.h"
#import "UIImageAdditions.h"

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
    
        // check the disk cache
        NSData * data = [self diskCacheContentsFor: url];
        if (data) {
            UIImage * img = [UIImage imageWithData: data];
            if (img) {
                [_imageCache setObject: img forKey: url];
                return img;
            } else
                [self clearDiskCacheContentsFor: url];
        }
    
        NSURLRequest * req = [NSURLRequest requestWithURL: url];
        
        // make sure there's not an open request for this image already
        for (AFImageRequestOperation * op in [_fetchQueue operations])
            if ([[[op request] URL] isEqual: url])
                return nil;
        
        AFHTTPRequestOperation * op = [[AFHTTPRequestOperation alloc] initWithRequest: req];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass: [NSData class]] == NO)
                return NSLog(@"No data returned for %@", [url description]);

            UIImage * image = [UIImage imageWithData: responseObject];
            if (!image)
                return NSLog(@"No image returned for %@", [url description]);
            
            [_imageCache setObject: image forKey: url];
            [self writeToDiskCache:responseObject fromURL: url];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_IMAGE_READY object:url];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            return NSLog(@"Error returned for %@", [error description]);
        }];
        [_fetchQueue addOperation: op];

        return nil;
    }
}

- (NSString*)diskCachePathFor:(NSURL*)url
{
    NSString * path = [[NSString stringWithFormat: @"~/tmp/cache/%@/%@?%@", [url host], [url path], [url query]] stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSData*)diskCacheContentsFor:(NSURL*)url
{
    return [NSData dataWithContentsOfFile: [self diskCachePathFor: url]];
}

- (void)writeToDiskCache:(NSData*)data fromURL:(NSURL*)url
{
    [data writeToFile:[self diskCachePathFor: url] atomically: NO];
}

- (void)clearDiskCacheContentsFor:(NSURL*)url
{
    [[NSFileManager defaultManager] removeItemAtPath:[self diskCachePathFor: url] error:nil];
}

- (UIImage*)blurredImageForURL:(NSURL*)url
{
    NSURL * blurredURL = [url URLByAppendingPathExtension:@"blurred"];

    if (!url) {
        return nil;

    } else if ([_imageCache objectForKey: blurredURL]) {
        return [_imageCache objectForKey: blurredURL];
        
    } else {
        
        // check the disk cache
        NSData * data = [self diskCacheContentsFor: blurredURL];
        if (data) {
            UIImage * img = [UIImage imageWithData: data];
            if (img) {
                [_imageCache setObject: img forKey: blurredURL];
                return img;
            } else
                [self clearDiskCacheContentsFor: blurredURL];
        }
        
        UIImage * img = [self imageForURL: url];
        if (!img)
            return nil;
        
        float desiredWidth = 200;
        float scaleFactor = desiredWidth / img.size.width;
        
        GPUImagePicture * picture = [[GPUImagePicture alloc] initWithImage:[img scaledImage: scaleFactor] smoothlyScaleOutput: NO];
        GPUImageGaussianBlurFilter * blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        
        [blurFilter setBlurSize: 0.5];
        [picture addTarget: blurFilter];
        [blurFilter addTarget: brightnessFilter];
        [brightnessFilter setBrightness: -0.3];
        
        [picture processImage];

        UIImage * result = [brightnessFilter imageFromCurrentlyProcessedOutput];
        [self writeToDiskCache: UIImagePNGRepresentation(result) fromURL: blurredURL];
        [_imageCache setObject: result forKey: blurredURL];
        return result;
    }
}

@end
