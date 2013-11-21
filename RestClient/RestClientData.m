//
//  RestClientData.m
//  RestClient
//
//  Created by Axel Rivera on 11/21/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RestClientData.h"

@implementation RestClientData

- (id)init
{
    self = [super init];
    if (self) {
        _groups = [@[] mutableCopy];
        _history = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _groups = [coder decodeObjectForKey:@"RestClientDataGroups"];
        _history = [coder decodeObjectForKey:@"RestClientDataHistory"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.groups forKey:@"RestClientDataGroups"];
    [coder encodeObject:self.history forKey:@"RestClientDataHistory"];
}

#pragma mark - Singleton Methods

+ (RestClientData *)sharedData
{
    static RestClientData *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[RestClientData alloc] init];
    });
    return sharedData;
}

@end
