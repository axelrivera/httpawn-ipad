//
//  RCSettings.h
//  RestClient
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRCSettingsEnableCookiesKey @"RCSettingsEnableCookiesKey"
#define kRCSettingsTimeoutIntervalKey @"RCSettingsTimeoutIntervalKey"
#define kRCSettingsAllowInvalidSSLKey @"RCSettingsAllowInvalidSSLKey"
#define kRCSettingsUsePrettyPrintResponseKey @"RCSettingsUsePrettyPrintResponseKey"
#define kRCSettingsApplySyntaxHighlightingKey @"RCSettingsApplySyntaxHighlightingKey"
#define kRCSettingsIncludeLineNumbersKey @"RCSettingsIncludeLineNumbersKey"

#define kRCSettingsDefaultEnableCookiesValue YES
#define kRCSettingsDefaultTimeoutIntervalValue 30.0
#define kRCSettingsDefaultAllowInvalidSSLValue YES
#define kRCSettingsDefaultUsePrettyPrintResponseValue YES
#define kRCSettingsDefaultApplySyntaxHighlightingValue YES
#define kRCSettingsDefaultIncludeLineNumbersValue YES

#define kRCSettingsTimeoutIntervalMinValue 2.0
#define kRCSettingsTimeoutIntervalMaxValue 180.0

@interface RCSettings : NSObject

- (BOOL)enableCookies;
- (void)setEnableCookies:(BOOL)flag;

- (CGFloat)timeoutInterval;
- (void)setTimeoutInterval:(CGFloat)interval;

- (BOOL)allowInvalidSSL;
- (void)setAllowInvalidSSL:(BOOL)flag;

- (BOOL)usePrettyPrintResponse;
- (void)setUsePrettyPrintResponse:(BOOL)flag;

- (BOOL)applySyntaxHighlighting;
- (void)setApplySyntaxHighlighting:(BOOL)flag;

- (BOOL)includeLineNumbers;
- (void)setIncludeLineNumbers:(BOOL)flag;

+ (RCSettings *)defaultSettings;

@end
