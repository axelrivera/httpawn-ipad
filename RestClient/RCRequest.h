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

typedef void (^RCRequestObjectResponse)(RCResponse *response, NSError *error);

@class AFHTTPRequestOperationManager;

@interface RCRequest : NSObject <NSCoding, NSCopying>

@property (weak, nonatomic) RCGroup *parentGroup;
@property (copy, nonatomic, readonly) NSString *identifier;
@property (copy, nonatomic) NSString *requestName;
@property (copy, nonatomic) NSString *requestDescription;
@property (strong, nonatomic) NSString *requestMethod;
@property (copy, nonatomic) NSString *URLString;
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *parameters;
@property (strong, nonatomic) RCResponse *response;
@property (strong, nonatomic, readonly) AFHTTPRequestOperationManager *manager;
@property (assign, nonatomic) BOOL followRedirects;
@property (assign, nonatomic) BOOL enableAuth;
@property (strong, nonatomic) NSString *basicAuthUsername;
@property (strong, nonatomic) NSString *basicAuthPassword;

- (id)initWithMethod:(NSString *)method URLString:(NSString *)URLString;

- (NSArray *)availableHeaders;
- (NSDictionary *)availableHeadersDictionary;

- (NSArray *)availableParameters;
- (NSDictionary *)availableParametersDictionary;

- (NSString *)fullURLString;

- (void)runWithCompletion:(RCRequestObjectResponse)completion;

- (BOOL)isEqualToRequest:(RCRequest *)request;

- (void)sanitize;

@end
