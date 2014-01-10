//
//  RCMeta.m
//  RestClient
//
//  Created by Axel Rivera on 1/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "RCMeta.h"

NSString * const RCMetaParameterEncodingDefaultString = @"default";
NSString * const RCMetaParameterEncodingFormString = @"form";
NSString * const RCMetaParameterEncodingJSONString = @"json";

NSString * const RCMetaParameterEncodingDefaultTitle = @"Default";
NSString * const RCMetaParameterEncodingFormTitle = @"Form";
NSString * const RCMetaParameterEncodingJSONTitle = @"JSON";

@implementation RCMeta

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enableAuth = NO;
        _basicAuthUsername = nil;
        _basicAuthPassword = nil;
        _followRedirects = YES;
        _parameterEncoding = RCMetaParameterEncodingDefaultString;
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

        if (dictionary[@"parameterEncoding"]) {
            _parameterEncoding = [[self class] titleForParameterEndoding:dictionary[@"parameterEncoding"]];
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

        NSString *parameterEncoding = [coder decodeObjectForKey:@"RCMetaParameterEncoding"];
        if (parameterEncoding == nil) {
            parameterEncoding = RCMetaParameterEncodingDefaultString;
        }

        _enableAuth = [enableAuth boolValue];
        _basicAuthUsername = [[coder decodeObjectForKey:@"RCMetaBasicAuthUsername"] copy];
        _basicAuthPassword = [[coder decodeObjectForKey:@"RCMetaBasicAuthPassword"] copy];
        _followRedirects = [followRedirects boolValue];
        _parameterEncoding = parameterEncoding;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.enableAuth forKey:@"RCMetaEnableAuth"];
    [coder encodeObject:self.basicAuthUsername forKey:@"RCMetaBasicAuthUsername"];
    [coder encodeObject:self.basicAuthPassword forKey:@"RCMetaBasicAuthPassword"];
    [coder encodeBool:self.followRedirects forKey:@"RCMetaFollowRedirects"];
    [coder encodeObject:self.parameterEncoding forKey:@"RCMetaParameterEncoding"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    RCMeta *myMeta = [[self class] allocWithZone:zone];
    myMeta.enableAuth = self.enableAuth;
    myMeta.basicAuthUsername = self.basicAuthUsername;
    myMeta.basicAuthPassword = self.basicAuthPassword;
    myMeta.followRedirects = self.followRedirects;
    myMeta.parameterEncoding = self.parameterEncoding;

    return myMeta;
}

+ (NSString *)parameterEncodingForString:(NSString *)string
{
    NSString *parameterEncoding = nil;
    if ([string isEqualToString:RCMetaParameterEncodingDefaultString]) {
        parameterEncoding = RCMetaParameterEncodingDefaultString;
    } else if ([string isEqualToString:RCMetaParameterEncodingFormString]) {
        parameterEncoding = RCMetaParameterEncodingFormString;
    } else if ([string isEqualToString:RCMetaParameterEncodingJSONString]) {
        parameterEncoding = RCMetaParameterEncodingJSONString;
    } else {
        parameterEncoding = RCMetaParameterEncodingDefaultString;
    }
    return parameterEncoding;
}

+ (NSString *)titleForParameterEndoding:(NSString *)parameterEncoding
{
    NSString *title = nil;
    if ([parameterEncoding isEqualToString:RCMetaParameterEncodingDefaultString]) {
        title = RCMetaParameterEncodingDefaultString;
    } else if ([parameterEncoding isEqualToString:RCMetaParameterEncodingFormString]) {
        title = RCMetaParameterEncodingFormString;
    } else if ([parameterEncoding isEqualToString:RCMetaParameterEncodingJSONString]) {
        title = RCMetaParameterEncodingJSONString;
    } else {
        title = RCMetaParameterEncodingDefaultString;
    }
    return title;
}

@end
