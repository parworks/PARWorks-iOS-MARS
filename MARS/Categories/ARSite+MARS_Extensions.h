//
//  ARSite+MARS_Extensions.h
//  MARS
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

#import "ARSite.h"
#import "ARSiteComment.h"

#define NOTIF_SITE_COMMENTS_UPDATED     @"NOTIF_SITE_COMMENTS_UPDATED"

@interface ARSite (MARS_Extensions)
@property (nonatomic, strong) NSMutableArray * comments;

- (void)fetchComments;
- (void)addComment:(ARSiteComment*)comment withCallback:(void(^)(NSString * err, ARSiteComment *comment))callback;
- (void)removeComment:(ARSiteComment*)comment withCallback:(void(^)(NSString * err))callback;

@end
