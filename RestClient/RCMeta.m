//
//  RCMeta.m
//  RestClient
//
//  Created by Axel Rivera on 1/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "RCMeta.h"

@implementation RCMeta

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableAuth = NO;
        _basicAuthUsername = nil;
        _basicAuthPassword = nil;
        _followRedirects = YES;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        NSNumber *enableAuth = dictionary[@"enableAuth"];
        if (enableAuth) {
            _enableAuth = [enableAuth boolValue];
        }

        NSString *basicAuthUsername = dictionary[@"basicAuthUsername"];
        if (basicAuthUsername) {
            _basicAuthUsername = [basicAuthUsername copy];
        }

        NSString *basicAuthPassword = dictionary[@"basicAuthPassword"];
        if (basicAuthPassword) {
            _basicAuthPassword = [basicAuthPassword copy];
        }

        NSNumber *followRedirects = dictionary[@"followRedirects"];
        if (followRedirects) {
            _followRedirects = [followRedirects boolValue];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        NSNumber *enableAuth = [coder decodeObjectForKey:@"RCMetaEnableAuth"];
        if (enableAuth == nil) {
            enableAuth = @NO;
        }

        NSNumber *followRedirects = [coder decodeObjectForKey:@"RCMetaFollowRedirects"];
        if (followRedirects == nil) {
            followRedirects = @YES;
        }

        _enableAuth = [enableAuth boolValue];
        _basicAuthUsername = [[coder decodeObjectForKey:@"RCMetaBasicAuthUsername"] copy];
        _basicAuthPassword = [[coder decodeObjectForKey:@"RCMetaBasicAuthPassword"] copy];
        _followRedirects = [followRedirects boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.enableAuth forKey:@"RCMetaEnableAuth"];
    [coder encodeObject:self.basicAuthUsername forKey:@"RCMetaBasicAuthUsername"];
    [coder encodeObject:self.basicAuthPassword forKey:@"RCMetaBasicAuthPassword"];
    [coder encodeBool:self.followRedirects forKey:@"RCMetaFollowRedirects"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    RCMeta *myMeta = [[RCMeta alloc] init];
    myMeta.enableAuth = self.enableAuth;
    myMeta.basicAuthUsername = self.basicAuthUsername;
    myMeta.basicAuthPassword = self.basicAuthPassword;
    myMeta.followRedirects = self.followRedirects;

    return myMeta;
}

@end
