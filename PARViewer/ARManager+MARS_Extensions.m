//
//  ARManager+MARS_Extensions.m
//  PARViewer
//
//  Created by Ben Gotow on 1/28/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARManager+MARS_Extensions.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "ARSite.h"

#import <objc/runtime.h>

#define TRENDING_SITES_PATH [@"~/Documents/Trending.plist" stringByExpandingTildeInPath]
#define FEATURED_TAGS_PATH [@"~/Documents/FeaturedTags.plist" stringByExpandingTildeInPath]
#define AVAILABLE_TAGS_PATH [@"~/Documents/AvailableTags.plist" stringByExpandingTildeInPath]

static char TRENDING_SITES_KEY;
static char AVAILABLE_TAGS_KEY;
static char FEATURED_TAGS_KEY;
static char CACHED_SITES_KEY;

@implementation ARManager (MARS_Extensions)

@dynamic trendingSites;
@dynamic availableTags;
@dynamic featuredTags;
@dynamic cachedSites;

- (void)setupCache
{
    NSCache * cache = [[NSCache alloc] init];
    [cache setCountLimit: 40];
    [self setCachedSites: cache];
}

- (void)stashMARSState
{
    [self.trendingSites writeToFile: TRENDING_SITES_PATH atomically:NO];
    [self.availableTags writeToFile: AVAILABLE_TAGS_PATH atomically:NO];
    [self.featuredTags writeToFile: FEATURED_TAGS_PATH atomically:NO];
}

- (void)restoreMARSState
{
    [self setTrendingSites: [NSArray arrayWithContentsOfFile: TRENDING_SITES_PATH]];
    [self setAvailableTags: [NSArray arrayWithContentsOfFile: AVAILABLE_TAGS_PATH]];
    [self setFeaturedTags: [NSArray arrayWithContentsOfFile: FEATURED_TAGS_PATH]];
}


- (void)fetchTrendingSites
{
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/list/trending" withMethod:@"GET" withArguments:nil];
    ASIHTTPRequest * __weak __req = req;
    
    if (self.cachedSites == nil)
        [self setupCache];
    
    [req setCompletionBlock: ^(void) {
        NSMutableArray * array = [NSMutableArray array];
        NSArray * json = [__req responseJSON];
        
        for (NSDictionary * dict in json) {
            ARSite * site = [[ARSite alloc] initWithInfo: dict];
            if (site) {
                [self.cachedSites setObject:site forKey:[site identifier]];
                [array addObject: site];
            }
        }
        
        [self setTrendingSites: array];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TRENDING_SITES_UPDATED object:nil];
    }];
    [req startAsynchronous];
}

- (void)fetchTags
{
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/tag/all" withMethod:@"GET" withArguments: nil];
    ASIHTTPRequest * __weak __req = req;
    [req setCompletionBlock: ^(void) {
        [self setAvailableTags: [__req responseJSON]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAGS_UPDATED object:nil];
    }];
    [req startAsynchronous];

    ASIHTTPRequest * featuredReq = [[ARManager shared] createRequest:@"/ar/site/tag/suggested" withMethod:@"GET" withArguments: nil];
    ASIHTTPRequest * __weak __featuredReq = featuredReq;
    [featuredReq setCompletionBlock: ^(void) {
        [self setFeaturedTags: [__featuredReq responseJSON]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAGS_UPDATED object:nil];
    }];
    [featuredReq startAsynchronous];
}

- (void)fetchTagResults:(NSString*)tagName withCallback:(void(^)(NSString * tagName, NSArray * sites))callback
{
    NSDictionary * args = [NSDictionary dictionaryWithObject:[tagName stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] forKey:@"tag"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/tag/list" withMethod:@"GET" withArguments: args];
    ASIHTTPRequest * __weak __req = req;
    
    if (self.cachedSites == nil)
        [self setupCache];
    
    [req setCompletionBlock: ^(void) {
        NSMutableArray * sites = [NSMutableArray array];
        NSArray * siteIDs = [__req responseJSON];
        
        for (NSString * siteID in siteIDs) {
            ARSite * site = [self.cachedSites objectForKey: siteID];
            if (!site) {
                site = [[ARSite alloc] initWithIdentifier: siteID];
                [self.cachedSites setObject:site forKey:siteID];
                [site fetchInfo];
            }
            [sites addObject: site];
        }
        
        callback(tagName, sites);
    }];
    
    [req startAsynchronous];
}

#pragma mark Associated Objects

- (NSMutableArray*)trendingSites
{
    return (NSMutableArray*)objc_getAssociatedObject(self, &TRENDING_SITES_KEY);
}

- (void)setTrendingSites:(NSArray *)trendingSites
{
    objc_setAssociatedObject(self, &TRENDING_SITES_KEY, trendingSites, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableArray*)availableTags
{
    return (NSMutableArray*)objc_getAssociatedObject(self, &AVAILABLE_TAGS_KEY);
}

- (void)setAvailableTags:(NSArray *)availableTags
{
    objc_setAssociatedObject(self, &AVAILABLE_TAGS_KEY, availableTags, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableArray*)featuredTags
{
    return (NSMutableArray*)objc_getAssociatedObject(self, &FEATURED_TAGS_KEY);
}

- (void)setFeaturedTags:(NSArray *)featuredTags
{
    objc_setAssociatedObject(self, &FEATURED_TAGS_KEY, featuredTags, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableArray*)cachedSites
{
    return (NSMutableArray*)objc_getAssociatedObject(self, &CACHED_SITES_KEY);
}

- (void)setCachedSites:(NSCache *)cachedSites
{
    objc_setAssociatedObject(self, &CACHED_SITES_KEY, cachedSites, OBJC_ASSOCIATION_RETAIN);
}

@end
