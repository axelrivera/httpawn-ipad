//
//  RCRequestObject.m
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCRequest.h"

#import <AFHTTPRequestOperationManager.h>

NSString * const RCRequestMethodGet = @"GET";
NSString * const RCRequestMethodPost = @"POST";
NSString * const RCRequestMethodPut = @"PUT";
NSString * const RCRequestMethodDelete = @"DELETE";
NSString * const RCRequestMethodHead = @"HEAD";
NSString * const RCRequestMethodTrace = @"TRACE";
NSString * const RCRequestMethodPatch = @"PATCH";

@interface RCRequest ()

@end

@implementation RCRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        //NSString *URLString = @"http://staging.lottry.co/api/v1/games.json?location_id=ny";
        NSString *URLString = @"http://httpawn-sharingan.fwd.wf";

        _parentGroup = nil;
        _identifier = [[NSString stringWithUUID] copy];
        _requestName = nil;
        _requestDescription = nil;
        _requestMethod = RCRequestMethodGet;
        _URLString = [URLString copy];
        _headers = @[];
        _parameters = @[];
        _response = nil;

        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_manager.operationQueue setMaxConcurrentOperationCount:1];

        _metadata = [[RCMeta alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _requestName = [dictionary[@"name"] copy];
        _requestDescription = [dictionary[@"description"] copy];
        _requestMethod = [[self class] requestMethodForString:[dictionary[@"method"] uppercaseString]];
        _URLString = [dictionary[@"url"] copy];

        NSArray *headersRaw = dictionary[@"headers"];
        if (headersRaw) {
            NSMutableArray *headers = [@[] mutableCopy];
            for (NSDictionary *dictionary in headersRaw) {
                RCRequestOption *option = [[RCRequestOption alloc] initWithDictionary:dictionary];
                [headers addObject:option];
            }
            _headers = [[NSArray alloc] initWithArray:headers];
        }

        NSArray *parametersRaw = dictionary[@"parameters"];
        if (parametersRaw) {
            NSMutableArray *parameters = [@[] mutableCopy];
            for (NSDictionary *dictionary in parametersRaw) {
                RCRequestOption *option = [[RCRequestOption alloc] initWithDictionary:dictionary];
                [parameters addObject:option];
            }
            _parameters = [[NSArray alloc] initWithArray:parameters];
        }

    }
    return self;
}

- (instancetype)initWithMethod:(NSString *)method URLString:(NSString *)URLString
{
    self = [self init];
    if (self) {
        _requestMethod = method;
        _URLString = [URLString copy];
    }
    return self;
}

#pragma mark - NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _parentGroup = [coder decodeObjectForKey:@"RCRequestParentGroup"];
        _identifier = [[coder decodeObjectForKey:@"RCRequestIdentifier"] copy];
        _requestName = [[coder decodeObjectForKey:@"RCRequestMethodName"] copy];
        _requestDescription = [[coder decodeObjectForKey:@"RCRequestMethodDescription"] copy];
        _requestMethod = [coder decodeObjectForKey:@"RCRequestMethodMethod"];
        _URLString = [[coder decodeObjectForKey:@"RCRequestURLString"] copy];
        _headers = [coder decodeObjectForKey:@"RCRequestHeaders"];
        _parameters = [coder decodeObjectForKey:@"RCRequestParameters"];
        _metadata = [coder decodeObjectForKey:@"RCRequestMetadata"];

        _response = nil;
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeConditionalObject:self.parentGroup forKey:@"RCRequestParentGroup"];
    [coder encodeObject:self.identifier forKey:@"RCRequestIdentifier"];
    [coder encodeObject:self.requestName forKey:@"RCRequestMethodName"];
    [coder encodeObject:self.requestDescription forKey:@"RCRequestMethodDescription"];
    [coder encodeObject:self.requestMethod forKey:@"RCRequestMethodMethod"];
    [coder encodeObject:self.URLString forKey:@"RCRequestURLString"];
    [coder encodeObject:self.headers forKey:@"RCRequestHeaders"];
    [coder encodeObject:self.parameters forKey:@"RCRequestParameters"];
    [coder encodeObject:self.metadata forKey:@"RCRequestMetadata"];
}

#pragma mark - NSCopying Methods

- (instancetype)copyWithZone:(NSZone *)zone
{
    RCRequest *myRequest = [[RCRequest alloc] initWithMethod:self.requestMethod URLString:self.URLString];
    myRequest.requestName = self.requestName;
    myRequest.requestDescription = self.requestDescription;
    myRequest.parentGroup = self.parentGroup;
    myRequest.headers = [[NSArray alloc] initWithArray:self.headers copyItems:YES];
    myRequest.parameters = [[NSArray alloc] initWithArray:self.parameters copyItems:YES];
    myRequest.metadata = self.metadata;
    myRequest.response = nil;
    
    return myRequest;
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
        myResponse.statusCode = [operation.response statusCode];
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

    if (self.metadata.enableAuth || (self.parentGroup && self.parentGroup.metadata.enableAuth)) {
        [self.manager.requestSerializer clearAuthorizationHeader];

        NSString *username = @"";
        NSString *password = @"";

        if (self.metadata.enableAuth) {
            username = self.metadata.basicAuthUsername;
            password = self.metadata.basicAuthPassword;
        } else {
            username = self.parentGroup.metadata.basicAuthUsername;
            username = self.parentGroup.metadata.basicAuthPassword;
        }

        [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username
                                                                       password:password];
    }

    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    [securityPolicy setAllowInvalidCertificates:[[RCSettings defaultSettings] allowInvalidSSL]];

    self.manager.securityPolicy = securityPolicy;
    
    NSMutableURLRequest *myRequest = [self.manager.requestSerializer requestWithMethod:self.requestMethod
                                                                             URLString:self.URLString
                                                                            parameters:parameters];
    myRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

    myRequest.HTTPShouldHandleCookies = [[RCSettings defaultSettings] enableCookies];
    myRequest.timeoutInterval = [[RCSettings defaultSettings] timeoutInterval];

    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:myRequest
                                                                              success:successBlock
                                                                              failure:failureBlock];

    if (!self.metadata.followRedirects || (self.parentGroup && !self.parentGroup.metadata.followRedirects)) {
        DLog(@"Should Ignore Redirect!");
        [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection,
                                                            NSURLRequest *request,
                                                            NSURLResponse *redirectResponse)
        {
            if (redirectResponse) {
                return nil;
            } else {
                return request;
            }
        }];
    }

    [operation start];
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

- (void)sanitize
{
    self.parentGroup = nil;
    self.requestName = nil;
    self.requestDescription = nil;
}

+ (NSString *)requestMethodForString:(NSString *)string
{
    NSString *method = nil;
    if ([string isEqualToString:RCRequestMethodGet]) {
        method = RCRequestMethodGet;
    } else if ([string isEqualToString:RCRequestMethodPost]) {
        method = RCRequestMethodPost;
    } else if ([string isEqualToString:RCRequestMethodPut]) {
        method = RCRequestMethodPut;
    } else if ([string isEqualToString:RCRequestMethodDelete]) {
        method = RCRequestMethodDelete;
    } else if ([string isEqualToString:RCRequestMethodHead]) {
        method = RCRequestMethodHead;
    } else if ([string isEqualToString:RCRequestMethodTrace]) {
        method = RCRequestMethodTrace;
    } else if ([string isEqualToString:RCRequestMethodPatch]) {
        method = RCRequestMethodPatch;
    } else {
        method = RCRequestMethodGet;
    }

    return method;
}

@end
