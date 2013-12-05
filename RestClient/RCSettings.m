//
//  RCSettings.m
//  RestClient
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCSettings.h"

@implementation RCSettings

#pragma mark - Singleton Methods

- (BOOL)enableCookies
{
    NSNumber *flag = [[self userDefaults] objectForKey:kRCSettingsEnableCookiesKey];
    if (flag == nil) {
        flag = [NSNumber numberWithBool:kRCSettingsDefaultEnableCookiesValue];
    }
    return [flag boolValue];
}

- (void)setEnableCookies:(BOOL)flag
{
    [[self userDefaults] setBool:flag forKey:kRCSettingsEnableCookiesKey];
    [[self userDefaults] synchronize];
}

- (CGFloat)timeoutInterval
{
    NSNumber *number = [[self userDefaults] objectForKey:kRCSettingsTimeoutIntervalKey];
    if (number == nil) {
        number = [NSNumber numberWithFloat:kRCSettingsDefaultTimeoutIntervalValue];
    }
    return [number floatValue];
}

- (void)setTimeoutInterval:(CGFloat)interval
{
    [[self userDefaults] setFloat:interval forKey:kRCSettingsTimeoutIntervalKey];
    [[self userDefaults] synchronize];
}

- (BOOL)allowInvalidSSL
{
    NSNumber *flag = [[self userDefaults] objectForKey:kRCSettingsAllowInvalidSSLKey];
    if (flag == nil) {
        flag = [NSNumber numberWithBool:kRCSettingsDefaultAllowInvalidSSLValue];
    }
    return [flag boolValue];
}

- (void)setAllowInvalidSSL:(BOOL)flag
{
    [[self userDefaults] setBool:flag forKey:kRCSettingsAllowInvalidSSLKey];
    [[self userDefaults] synchronize];
}

- (BOOL)usePrettyPrintResponse
{
    NSNumber *flag = [[self userDefaults] objectForKey:kRCSettingsUsePrettyPrintResponseKey];
    if (flag == nil) {
        flag = [NSNumber numberWithBool:kRCSettingsDefaultUsePrettyPrintResponseValue];
    }
    return [flag boolValue];
}

- (void)setUsePrettyPrintResponse:(BOOL)flag
{
    [[self userDefaults] setBool:flag forKey:kRCSettingsUsePrettyPrintResponseKey];
    [[self userDefaults] synchronize];
}

- (BOOL)applySyntaxHighlighting
{
    NSNumber *flag = [[self userDefaults] objectForKey:kRCSettingsApplySyntaxHighlightingKey];
    if (flag == nil) {
        flag = [NSNumber numberWithBool:kRCSettingsDefaultApplySyntaxHighlightingValue];
    }
    return [flag boolValue];
}

- (void)setApplySyntaxHighlighting:(BOOL)flag
{
    [[self userDefaults] setBool:flag forKey:kRCSettingsApplySyntaxHighlightingKey];
    [[self userDefaults] synchronize];
}

- (BOOL)includeLineNumbers
{
    NSNumber *flag = [[self userDefaults] objectForKey:kRCSettingsIncludeLineNumbersKey];
    if (flag == nil) {
        flag = [NSNumber numberWithBool:kRCSettingsDefaultIncludeLineNumbersValue];
    }
    return [flag boolValue];
}

- (void)setIncludeLineNumbers:(BOOL)flag
{
    [[self userDefaults] setBool:flag forKey:kRCSettingsIncludeLineNumbersKey];
    [[self userDefaults] synchronize];
}

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

+ (RCSettings *)defaultSettings
{
    static RCSettings *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[RCSettings alloc] init];
    });
    return shared;
}


@end
