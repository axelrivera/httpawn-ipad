//
//  ResponseObject.h
//  RestClient
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCResponse : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger statusCode;
@property (copy, nonatomic) NSString *statusCodeString;

@property (assign, nonatomic) NSTimeInterval responseTime;

@property (strong, nonatomic) NSDictionary *headersDictionary;

@property (strong, nonatomic) NSString *requestURLString;

@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) NSString *responseString;
@property (assign, nonatomic) NSStringEncoding responseStringEncoding;

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
