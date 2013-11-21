//
//  NSArray+RestClient.m
//  RestClient
//
//  Created by Axel Rivera on 8/14/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSArray+RestClient.h"

NSString * const RCRequestMethodGet = @"GET";
NSString * const RCRequestMethodPost = @"POST";
NSString * const RCRequestMethodPut = @"PUT";
NSString * const RCRequestMethodDelete = @"DELETE";
NSString * const RCRequestMethodHead = @"HEAD";

@implementation NSArray (RestClient)

+ (NSArray *)availableHTTPActions
{
    return @[ RCRequestMethodGet, RCRequestMethodPost, RCRequestMethodPut, RCRequestMethodDelete ];
}

- (NSArray *)arrayOfAvailableObjects
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isOn == YES"];
    return [self filteredArrayUsingPredicate:predicate];
}

- (NSDictionary *)dictionaryOfAvailableObjects
{
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    NSArray *availableObjects = [self arrayOfAvailableObjects];

    for (id object in availableObjects) {
        if ([object respondsToSelector:@selector(objectName)] && [object respondsToSelector:@selector(stringValue)]) {
            dictionary[[object objectName]] = [object stringValue];
        }
    }
    return dictionary;
}

@end
