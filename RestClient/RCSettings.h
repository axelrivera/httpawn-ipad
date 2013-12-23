//
//  RCSettings.h
//  RestClient
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRCSettingsResponseFontSizeKey @"RCSettingsResponseFontSizeKey"
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

FOUNDATION_EXPORT NSString * const RCSettingsResponseFontSizeSmall;
FOUNDATION_EXPORT NSString * const RCSettingsResponseFontSizeMedium;
FOUNDATION_EXPORT NSString * const RCSettingsResponseFontSizeLarge;

@interface RCSettings : NSObject

- (NSString *)responseFontSize;
- (void)setResponseFontSize:(NSString *)fontSize;
- (NSInteger)indexForCurrentResponseFontSize;

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
