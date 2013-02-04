//
//  NSString+DateConversion.h
//  Mib.io
//
//  Created by Ben Gotow on 6/7/12.
//  Copyright (c) 2012 Foundry376. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConversion)

+ (NSString*)stringWithDate:(NSDate*)date format:(NSString*)f;
- (NSDate*)dateValueWithFormat:(NSString*)f;


@end
