//
//  NSString+RestClient.m
//  RestClient
//
//  Created by Axel Rivera on 8/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSString+RestClient.h"

@implementation NSString (Kumo)

- (BOOL)isEmpty
{
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return IsEmpty(string);
}

- (BOOL)isValidHTTPURL
{    
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"] ? YES : NO;
}

- (NSString *)cleanString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
