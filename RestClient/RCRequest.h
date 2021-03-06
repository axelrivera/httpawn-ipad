//
//  RCRequestObject.h
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCGroup.h"
#import "RCRequest.h"
#import "RCResponse.h"
#import "RCRequestOption.h"

FOUNDATION_EXPORT NSString * const RCRequestMethodGet;
FOUNDATION_EXPORT NSString * const RCRequestMethodPost;
FOUNDATION_EXPORT NSString * const RCRequestMethodPut;
FOUNDATION_EXPORT NSString * const RCRequestMethodDelete;
FOUNDATION_EXPORT NSString * const RCRequestMethodHead;
FOUNDATION_EXPORT NSString * const RCRequestMethodTrace;
FOUNDATION_EXPORT NSString * const RCRequestMethodPatch;

typedef void (^RCRequestObjectResponse)(RCResponse *response, NSError *error);

@class AFHTTPRequestOperationManager;
@class RCJSONObject;

@interface RCRequest : NSObject <NSCoding, NSCopying>

@property (weak, nonatomic) RCGroup *parentGroup;
@property (copy, nonatomic, readonly) NSString *identifier;
@property (copy, nonatomic) NSString *requestName;
@property (copy, nonatomic) NSString *requestDescription;
@property (strong, nonatomic) NSString *requestMethod;
@property (copy, nonatomic) NSString *URLString;
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *parameters;
@property (strong, nonatomic) RCJSONObject *JSONParameters;
@property (strong, nonatomic) RCResponse *response;
@property (strong, nonatomic, readonly) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) RCMeta *metadata;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithMethod:(NSString *)method URLString:(NSString *)URLString;

- (NSArray *)availableHeaders;
- (NSDictionary *)availableHeadersDictionary;

- (NSArray *)availableParameters;
- (NSDictionary *)availableParametersDictionary;

- (NSString *)absoluteURLString;
- (NSString *)requestURLString;

- (void)runWithCompletion:(RCRequestObjectResponse)completion;

- (BOOL)isEqualToRequest:(RCRequest *)request;

- (void)sanitize;
- (void)saveDataFromRequest:(RCRequest *)request;

- (BOOL)enableAuth;
- (BOOL)followRedirects;
- (NSString *)parameterEncoding;

+ (NSString *)requestMethodForString:(NSString *)string;

@end
