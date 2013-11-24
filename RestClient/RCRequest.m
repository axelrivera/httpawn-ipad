//
//  RCRequestObject.m
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCRequest.h"

#import <AFHTTPRequestOperationManager.h>

@interface RCRequest ()

@end

@implementation RCRequest

- (id)init
{
    self = [super init];
    if (self) {
        _requestName = nil;
        _requestDescription = nil;
        _requestMethod = RCRequestMethodGet;
        _URLString = [@"" copy];
        _headers = @[];
        _parameters = @[];
        _response = nil;
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (id)initWithMethod:(NSString *)method URLString:(NSString *)URLString
{
    self = [self init];
    if (self) {
        [_manager.operationQueue setMaxConcurrentOperationCount:1];
        _requestMethod = method;
        _URLString = [URLString copy];
    }
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _requestName = [[coder decodeObjectForKey:@"RCRequestMethodName"] copy];
        _requestDescription = [[coder decodeObjectForKey:@"RCRequestMethodDescription"] copy];
        _requestMethod = [coder decodeObjectForKey:@"RCRequestMethodMethod"];
        _URLString = [[coder decodeObjectForKey:@"RCRequestURLString"] copy];
        _headers = [coder decodeObjectForKey:@"RCRequestHeaders"];
        _parameters = [coder decodeObjectForKey:@"RCRequestParameters"];
        _response = nil;
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.requestName forKey:@"RCRequestMethodName"];
    [coder encodeObject:self.requestDescription forKey:@"RCRequestMethodDescription"];
    [coder encodeObject:self.requestMethod forKey:@"RCRequestMethodMethod"];
    [coder encodeObject:self.URLString forKey:@"RCRequestURLString"];
    [coder encodeObject:self.headers forKey:@"RCRequestHeaders"];
    [coder encodeObject:self.parameters forKey:@"RCRequestParameters"];
}

#pragma mark - Public Methods

- (void)setHeaders:(NSArray *)headers
{
    _headers = headers;
    if (self.manager) {
        NSDictionary *availableHeaders = [headers dictionaryOfAvailableObjects];
        [availableHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}

- (NSArray *)availableHeaders
{
    return [self.headers arrayOfAvailableObjects];
}

- (NSDictionary *)availableHeadersDictionary
{
    return [self.headers dictionaryOfAvailableObjects];
}

- (NSArray *)availableParameters
{
    return [self.parameters arrayOfAvailableObjects];
}

- (NSDictionary *)availableParametersDictionary
{
    return [self.parameters dictionaryOfAvailableObjects];
}

- (NSString *)fullURLString
{
    NSArray *availableParameters = [self availableParameters];
    NSMutableArray *parameters = [@[] mutableCopy];
    for (RCRequestOption *parameter in availableParameters) {
        NSString *str = [NSString stringWithFormat:@"%@=%@", parameter.objectName, parameter.objectValue];
        [parameters addObject:str];
    }

    NSString *str = nil;
    if ([parameters count] > 0) {
        NSString *parametersStr = [parameters componentsJoinedByString:@"&"];
        str = [NSString stringWithFormat:@"%@?%@", self.URLString, parametersStr];
    } else {
        str = self.URLString;
    }

    return str;
}

- (void)runWithCompletion:(RCRequestObjectResponse)completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self availableParametersDictionary]
                                                                            copyItems:YES];

    NSTimeInterval startTime = CFAbsoluteTimeGetCurrent();

    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval endTime = CFAbsoluteTimeGetCurrent();

        NSString *statusString = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
        DLog(@"Response: %ld (%@)", (long)operation.response.statusCode, statusString);
        DLog(@"URL: %@", [operation.response.URL absoluteString]);
        
        RCResponse *myResponse = [[RCResponse alloc] init];
        myResponse.statusCode = operation.response.statusCode;
        myResponse.statusCodeString = statusString;
        myResponse.requestURLString = [operation.request.URL absoluteString];
        myResponse.headersDictionary = [operation.response allHeaderFields];
        myResponse.responseData = operation.responseData;
        myResponse.responseString = operation.responseString;
        myResponse.responseStringEncoding = [operation responseStringEncoding];
        myResponse.responseTime = (endTime - startTime) * 1000.0;
        
        self.response = myResponse;
        
        if (completion) {
            completion(self.response, nil);
        }
    };
    
    void (^failureBlock)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSTimeInterval endTime = CFAbsoluteTimeGetCurrent();

        DLog(@"Request Failed: %@", error);
        
        RCResponse *myResponse = [[RCResponse alloc] init];
        myResponse.statusCode = operation.response.statusCode;
        myResponse.statusCodeString = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
        myResponse.requestURLString = [operation.request.URL absoluteString];
        myResponse.headersDictionary = [operation.response allHeaderFields];
        myResponse.responseStringEncoding = operation.responseStringEncoding;
        myResponse.responseTime = (endTime - startTime) * 1000.0;
        
        if ([error localizedRecoverySuggestion]) {
            myResponse.responseString = [error localizedRecoverySuggestion];
        } else {
            if ([error localizedDescription]) {
                myResponse.responseString = [error localizedDescription];
            }
        }
        
        myResponse.responseData = [myResponse.responseString dataUsingEncoding:myResponse.responseStringEncoding];
        
        self.response = myResponse;
        
        if (completion) {
            completion(self.response, error);
        }
    };
    
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:self.requestMethod
                                                                           URLString:self.URLString
                                                                          parameters:parameters];

    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                            success:successBlock
                                                                            failure:failureBlock];
    [operation start];
}

- (id)copyWithZone:(NSZone *)zone
{
    RCRequest *myRequest = [[RCRequest alloc] initWithMethod:self.requestMethod URLString:self.URLString];
    myRequest.headers = [[NSArray alloc] initWithArray:self.headers copyItems:YES];
    myRequest.parameters = [[NSArray alloc] initWithArray:self.parameters copyItems:YES];
    myRequest.response = nil;

    return myRequest;
}

- (BOOL)isEqualToRequest:(RCRequest *)request
{
    BOOL isMethodEqual = NO;
    BOOL isURLEqual = NO;
    BOOL isParametersEqual = YES;
    BOOL isHeadersEqual = YES;

    NSString *myMethod = [self requestMethod];
    NSString *theirMethod = [request requestMethod];
    isMethodEqual = myMethod && theirMethod ? [myMethod isEqualToString:theirMethod] : NO;

    NSString *myString = [self URLString];
    NSString *theirString = [request URLString];
    isURLEqual = myString && theirString ? [myString isEqualToString:theirString] : NO;

    if (isMethodEqual && isURLEqual) {
        if ([self.parameters count] == [request.parameters count]) {
            for (RCRequestOption *myParameter in self.parameters) {
                for (RCRequestOption *theirParameter in request.parameters) {
                    if (![myParameter isEqualToRequestOption:theirParameter]) {
                        isParametersEqual = NO;
                        break;
                    }
                }
                
            }
        }

        if (isParametersEqual) {
            if ([self.headers count] == [request.headers count]) {
                for (RCRequestOption *myHeader in self.headers) {
                    for (RCRequestOption *theirHeader in request.headers) {
                        if (![myHeader isEqualToRequestOption:theirHeader]) {
                            isHeadersEqual = NO;
                            break;
                        }
                    }
                }
            }
        }
    }

	return isMethodEqual && isURLEqual && isParametersEqual && isHeadersEqual ? YES : NO;
}

@end
