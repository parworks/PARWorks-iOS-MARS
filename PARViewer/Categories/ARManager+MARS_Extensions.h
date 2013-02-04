//
//  ARManager+MARS_Extensions.h
//  PARViewer
//
//  Created by Ben Gotow on 1/28/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARManager.h"

#define NOTIF_TAGS_UPDATED              @"NOTIF_TAGS_UPDATED"
#define NOTIF_TRENDING_SITES_UPDATED    @"NOTIF_TRENDING_SITES_UPDATED"

@interface ARManager (MARS_Extensions)

@property (nonatomic, retain) NSCache * cachedSites;
@property (nonatomic, retain) NSArray * trendingSites;

@property (nonatomic, retain) NSArray * availableTags;
@property (nonatomic, retain) NSArray * featuredTags;

- (void)stashMARSState;
- (void)restoreMARSState;

- (void)fetchTrendingSites;
- (void)fetchTags;
- (void)fetchTagResults:(NSString*)tagName withCallback:(void(^)(NSString * tagName, NSArray * sites))callback;

@end
