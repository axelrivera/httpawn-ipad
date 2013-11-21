//
//  NSData+RestClient.h
//  RestClient
//
//  Created by Axel Rivera on 8/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (RestClient)

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding;

//- (NSString *)XMLStringWithEncoding:(NSStringEncoding)encoding;
//- (NSString *)formattedXMLStringWithEncoding:(NSStringEncoding)encoding;

- (id)JSONObject;
- (NSString *)JSONStringWithEncoding:(NSStringEncoding)encoding;
- (NSString *)formattedJSONStringWithEncoding:(NSStringEncoding)encoding;

@end
