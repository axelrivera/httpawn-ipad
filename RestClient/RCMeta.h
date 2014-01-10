//
//  RCMeta.h
//  RestClient
//
//  Created by Axel Rivera on 1/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingDefaultString;
FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingFormString;
FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingJSONString;

FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingDefaultTitle;
FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingFormTitle;
FOUNDATION_EXPORT NSString * const RCMetaParameterEncodingJSONTitle;

@interface RCMeta : NSObject <NSCopying, NSCoding>

@property (assign, nonatomic) BOOL enableAuth;
@property (copy, nonatomic) NSString *basicAuthUsername;
@property (copy, nonatomic) NSString *basicAuthPassword;
@property (assign, nonatomic) BOOL followRedirects;
@property (strong, nonatomic) NSString *parameterEncoding;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (NSString *)parameterEncodingForString:(NSString *)string;
+ (NSString *)titleForParameterEndoding:(NSString *)parameterEncoding;

@end
