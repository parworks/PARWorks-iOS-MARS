//
//  ARSiteComment.m
//  PARViewer
//
//  Created by Ben Gotow on 1/28/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import "ARSiteComment.h"
#import "NSContainers+NullHandlers.h"

@implementation ARSiteComment

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        [self setTimestamp: [NSDate dateWithTimeIntervalSince1970: [[dict objectForKey: @"timeStamp"] doubleValue] / 1000.0]];
        [self setUserID: [dict objectForKey: @"userId" or:nil]];
        [self setUserName: [dict objectForKey: @"userName" or: nil]];
        [self setBody: [dict objectForKey: @"comment" or:nil]];
    }
    return self;
}


@end
