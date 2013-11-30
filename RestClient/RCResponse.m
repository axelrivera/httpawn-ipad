//
//  ResponseObject.m
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCResponse.h"

#import "NSData+RestClient.h"

@implementation RCResponse

- (id)init
{
    self = [super init];
    if (self) {
        _statusCode = 0;
        _statusCodeString = @"";
        _responseTime = 0.0;
        _requestURLString = @"";
        _headersDictionary = @{};
        _responseData = [NSData data];
        _responseString = @"";
        _responseStringEncoding = NSUTF8StringEncoding;
    }
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _statusCode = [[coder decodeObjectForKey:@"RCResponseStatusCode"] integerValue];
        _statusCodeString = [[coder decodeObjectForKey:@"RCResponsetStatusCodeString"] copy];
        _requestURLString = [coder decodeObjectForKey:@"RCResponseRequestURLString"];
        _headersDictionary = [coder decodeObjectForKey:@"RCResponseHeadersDictionary"];
        _responseData = [coder decodeObjectForKey:@"RCResponseResponseData"];
        _responseString = [coder decodeObjectForKey:@"RCResponseResponseString"];
        _responseStringEncoding = [[coder decodeObjectForKey:@"RCResponseResponseStringEncoding"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.statusCode forKey:@"RCResponseStatusCode"];
    [coder encodeObject:self.statusCodeString forKey:@"RCResponseStatusCodeString"];
    [coder encodeObject:self.requestURLString forKey:@"RCResponseRequestURLString"];
    [coder encodeObject:self.headersDictionary forKey:@"RCResponseHeadersDictionary"];
    [coder encodeObject:self.responseData forKey:@"RCResponseResponseData"];
    [coder encodeObject:self.responseString forKey:@"RCResponseResponseString"];
    [coder encodeInteger:self.responseStringEncoding forKey:@"RCResponseResponseStringEncoding"];
}

#pragma mark - Public Methods

- (NSString *)contentType
{
    NSString *string = @"text/plain";
    NSString *headerContentType = self.headersDictionary[@"Content-Type"];
    if (headerContentType) {
        NSArray *array = [headerContentType componentsSeparatedByString:@";"];
        if (array && [array count] > 0) {
            string = array[0];
        }
    }
    return string;
}

- (BOOL)isXML
{
    BOOL retValue = NO;
    NSRange range = [[self contentType] rangeOfString:@"xml"];
    if (range.location != NSNotFound) {
        retValue = YES;
    }
    return retValue;
}

- (BOOL)isHTML
{
    BOOL retValue = NO;
    NSRange range = [[self contentType] rangeOfString:@"text/html"];
    if (range.location != NSNotFound) {
        retValue = YES;
    }
    return retValue;
}

- (BOOL)isJSON
{
    BOOL retValue = NO;
    NSRange range = [[self contentType] rangeOfString:@"application/json"];
    if (range.location != NSNotFound) {
        retValue = YES;
    }
    return retValue;
}

- (NSDictionary *)responseDictionary
{
    NSDictionary *dictionary = @{};
    if ([self isJSON]) {
        id object = [self.responseData JSONObject];
        if ([object isKindOfClass:[NSDictionary class]]) {
            dictionary = object;
        }
    }
    return dictionary;
}

- (NSString *)formattedBodyString
{
    NSString *string = @"";
    if ([self isJSON]) {
        string = [self.responseData formattedJSONStringWithEncoding:self.responseStringEncoding];
    } else {
        string = [self.responseData stringWithEncoding:self.responseStringEncoding];
    }
    return string;
}

- (NSString *)bodyString
{
    return [self.responseData stringWithEncoding:self.responseStringEncoding];
}

- (NSString *)statusString
{
    NSString *string = [NSString stringWithFormat:@"STATUS: %ld (%@)\nURL: %@",
                        (long)self.statusCode,
                        [self.statusCodeString uppercaseString],
                        self.requestURLString];
    return string;
}

- (NSString *)headerString
{
    NSMutableString *string = [@"" mutableCopy];
    [string appendString:[self statusString]];
    if (self.headersDictionary) {
        [string appendString:@"\n\n"];
        [string appendString:[self.headersDictionary stringFromHeaders]];
    }
    return string;
}

- (NSString *)headerAndBodyString
{
    NSMutableString *string = [@"" mutableCopy];
    [string appendString:[self headerString]];
    [string appendFormat:@"\n==================================================\n\n"];
    [string appendString:[self formattedBodyString]];
    return string;
}

- (NSString *)rawString
{
    return self.bodyString;
}

@end
