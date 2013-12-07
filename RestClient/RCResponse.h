//
//  ResponseObject.h
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCResponse : NSObject <NSCoding>

@property (copy, nonatomic) NSString *requestURLString;
@property (strong, nonatomic) NSDictionary *headersDictionary;
@property (assign, nonatomic) NSInteger statusCode;
@property (copy, nonatomic) NSString *statusCodeString;

@property (copy, nonatomic) NSData *responseData;
@property (copy, nonatomic) NSString *responseString;
@property (assign, nonatomic) NSStringEncoding responseStringEncoding;

@property (assign, nonatomic) NSTimeInterval responseTime;

- (NSString *)contentType;

- (BOOL)isXML;
- (BOOL)isJSON;
- (BOOL)isHTML;

- (NSDictionary *)responseDictionary;

- (NSString *)formattedBodyString;
- (NSAttributedString *)formattedAttributedBodyString;
- (NSString *)bodyString;
- (NSString *)statusString;
- (NSString *)headerString;
- (NSString *)headerAndBodyString;
- (NSString *)rawString;

@end
