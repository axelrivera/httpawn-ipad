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
        _manager = [AFHTTPRequestOperationManager manager];
        _method = RCRequestMethodGet;
        _URLString = [@"" copy];
        _headers = @[];
        _parameters = @[];
        _response = nil;
    }
    return self;
}

- (id)initWithMethod:(NSString *)method URLString:(NSString *)URLString
{
    self = [self init];
    if (self) {
        [_manager.operationQueue setMaxConcurrentOperationCount:1];
        _method = method;
        _URLString = [URLString copy];
    }
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _method = [coder decodeObjectForKey:@"RCRequestMethod"];
        _URLString = [[coder decodeObjectForKey:@"RCRequestURLString"] copy];
        _headers = [coder decodeObjectForKey:@"RCRequestHeaders"];
        _parameters = [coder decodeObjectForKey:@"RCRequestParameters"];
        _response = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.method forKey:@"RCRequestMethod"];
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

- (void)runWithCompletion:(RCRequestObjectResponse)completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self availableParametersDictionary]
                                                                            copyItems:YES];
    
    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
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
        
        self.response = myResponse;
        
        if (completion) {
            completion(self.response, nil);
        }
    };
    
    void (^failureBlock)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request Failed: %@", error);
        
        RCResponse *myResponse = [[RCResponse alloc] init];
        myResponse.statusCode = operation.response.statusCode;
        myResponse.statusCodeString = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
        myResponse.requestURLString = [operation.request.URL absoluteString];
        myResponse.headersDictionary = [operation.response allHeaderFields];
        myResponse.responseStringEncoding = operation.responseStringEncoding;
        
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
    
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:self.method
                                                                           URLString:self.URLString
                                                                          parameters:parameters];

    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                            success:successBlock
                                                                            failure:failureBlock];
    [operation start];
}


@end
