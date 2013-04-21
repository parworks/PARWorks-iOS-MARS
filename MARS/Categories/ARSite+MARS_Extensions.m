//
//  ARSite+MARS_Extensions.m
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

#import "ARSite+MARS_Extensions.h"
#import "ASIHTTPRequest+JSONAdditions.h"
#import "ARManager.h"

#import <objc/runtime.h>

static char COMMENTS_KEY;

@implementation ARSite (MARS_Extensions)

@dynamic comments;

- (void)fetchComments
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/comment/list" withMethod:@"GET" withArguments: dict];
    ASIHTTPRequest * __weak __req = req;
    
    [req setCompletionBlock: ^(void) {
        NSMutableArray * array = [NSMutableArray array];
        NSArray * json = [__req responseJSON];
        
        for (NSDictionary * dict in json)
            [array addObject: [[ARSiteComment alloc] initWithDictionary: dict]];
        
        [self setComments: array];
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_SITE_COMMENTS_UPDATED object: self];
    }];
    [req startAsynchronous];
}

- (void)addComment:(ARSiteComment*)comment withCallback:(void(^)(NSString * err, ARSiteComment *comment))callback
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    [dict setObject: [comment userName] forKey:@"userName"];
    [dict setObject: [comment userID] forKey:@"userId"];
    [dict setObject: [comment body] forKey:@"comment"];
    
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/comment/add" withMethod:@"GET" withArguments: dict];
    ASIHTTPRequest * __weak __req = req;
    [req setCompletionBlock: ^(void) {
        NSDictionary * response = [__req responseJSON];
        if ([[response objectForKey: @"success"] intValue] == 1)
            callback(NULL, comment);
        else
            callback(@"Sorry, your comment could not be saved.", nil);
    }];
    [req startAsynchronous];
}

- (void)removeComment:(ARSiteComment*)comment withCallback:(void(^)(NSString * err))callback
{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:self.identifier forKey:@"site"];
    [dict setObject:[NSString stringWithFormat:@"%.0f", [comment.timestamp timeIntervalSince1970] * 1000] forKey:@"timeStamp"];
    ASIHTTPRequest * req = [[ARManager shared] createRequest:@"/ar/site/comment/remove" withMethod:@"GET" withArguments: dict];
    ASIHTTPRequest * __weak __req = req;
    [req setCompletionBlock: ^(void) {
        NSDictionary * response = [__req responseJSON];
        if ([[response objectForKey: @"success"] intValue] == 1)
            callback(NULL);
        else
            callback(@"Sorry, your comment could not be deleted.");
    }];
    [req startAsynchronous];
}

#pragma mark Associated Objects

- (NSMutableArray*)comments
{
    return (NSMutableArray*)objc_getAssociatedObject(self, &COMMENTS_KEY);
}

- (void)setComments:(NSMutableArray*)comments
{
    objc_setAssociatedObject(self, &COMMENTS_KEY, comments, OBJC_ASSOCIATION_RETAIN);
}

@end
