//
//  NSString+DateConversion.m
//  Mib.io
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
