//
//  ARManager+MARS_Extensions.h
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
