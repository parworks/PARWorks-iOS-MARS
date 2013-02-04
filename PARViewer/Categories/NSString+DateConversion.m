//
//  NSString+DateConversion.m
//  Mib.io
//
//  Created by Ben Gotow on 6/7/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import "NSString+DateConversion.h"

static NSMutableDictionary * formatters;


@implementation NSString (DateConversion)

+ (NSDateFormatter*)formatterForFormat:(NSString*) f
{
    if (formatters == nil)
        formatters = [[NSMutableDictionary alloc] init];
    
    NSDateFormatter * formatter = [formatters objectForKey: f];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: f];
        [formatters setObject: formatter forKey: f];
    }
    return formatter;
}

+ (NSString*)stringWithDate:(NSDate*)date format:(NSString*)f
{
    return [[NSString formatterForFormat: f] stringFromDate: date];
}

- (NSDate*)dateValueWithFormat:(NSString*)f
{
    return [[NSString formatterForFormat: f] dateFromString: self];
}



@end
