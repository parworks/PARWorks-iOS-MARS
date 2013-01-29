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
    // doesn't work yet
    [self setAvailableTags: @[@"#SXSW", @"#PRIUS", @"Foundry376", @"PARwesome", @"HelloWorld", @"Alphabet"]];
    [self setFeaturedTags: @[@"#SXSW", @"#PRIUS", @"Foundry376", @"PARwesome"]];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_TAGS_UPDATED object:nil];
}

- (void)fetchTagResults:(NSString*)tagName withCallback:(void(^)(NSString * tagName, NSArray * sites))callback
{
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/list/trending" withMethod:@"GET" withArguments:nil];
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
                [self.cachedSites setObject:siteID forKey:siteID];
                [site fetchInfo];
            }
            [sites addObject: site];
        }
        
        callback(tagName, sites);
    }];
}

@end
