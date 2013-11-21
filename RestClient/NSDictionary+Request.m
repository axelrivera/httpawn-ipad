//
//  NSDictionary+Request.m
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSDictionary+Request.h"

@implementation NSDictionary (Request)

- (NSString *)stringFromHeaders
{
    __block NSMutableString *string = [@"" mutableCopy];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"%@: %@\n", key, obj];
    }];

    return string;
}

@end
