//
//  ARSite+MARS_Extensions.h
//  PARViewer
//
//  Created by Ben Gotow on 1/28/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
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
