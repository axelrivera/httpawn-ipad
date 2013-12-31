//
//  RCPredefinedHeader.m
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCPredefinedHeader.h"

#import "NSJSONSerialization+File.h"

@implementation RCPredefinedHeader

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _headerName = [dictionary[@"name"] copy];

        NSArray *values = dictionary[@"values"];
        if (IsEmpty(values)) {
            values = @[];
        }
        _headerValues = [[NSArray alloc] initWithArray:values copyItems:YES];
    }
    return self;
}

+ (NSArray *)allPredefinedHeaders
{
    NSString *file = [[NSBundle mainBundle] pathForResource:kRestClientPredefinedHeadersFile
                                                     ofType:kRstClientPredefinedHeadersExtension];

    NSDictionary *object = [NSJSONSerialization rc_JSONObjectWithContentsOfFile:file];
    NSArray *headersRaw = object[@"headers"];

     NSMutableArray *headers = [@[] mutableCopy];

    if (headers) {
        for (NSDictionary *dictionary in headersRaw) {
            RCPredefinedHeader *header = [[RCPredefinedHeader alloc] initWithDictionary:dictionary];
            [headers addObject:header];
        }
    }

    return headers;
}

@end
