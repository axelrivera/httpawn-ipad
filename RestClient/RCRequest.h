//
//  RCRequestObject.h
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRequest.h"
#import "RCResponse.h"
#import "RCRequestOption.h"

typedef void (^RCRequestObjectResponse)(RCResponse *response, NSError *error);

@class AFHTTPRequestOperationManager;

@interface RCRequest : NSObject <NSCoding>

@property (strong, nonatomic, readonly) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSString *method;
@property (copy, nonatomic) NSString *URLString;
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *parameters;
@property (strong, nonatomic) RCResponse *response;

- (id)initWithMethod:(NSString *)method URLString:(NSString *)URLString;

- (NSArray *)availableHeaders;
- (NSDictionary *)availableHeadersDictionary;

- (NSArray *)availableParameters;
- (NSDictionary *)availableParametersDictionary;

- (void)runWithCompletion:(RCRequestObjectResponse)completion;

@end
