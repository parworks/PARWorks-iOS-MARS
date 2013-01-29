//
//  ARSiteComment.h
//  PARViewer
//
//  Created by Ben Gotow on 1/28/13.
//  Copyright (c) 2013 Ben Gotow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARSiteComment : NSObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDate * timestamp;

- (id)initWithDictionary:(NSDictionary*)dict;

@end
