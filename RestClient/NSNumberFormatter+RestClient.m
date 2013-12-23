//
//  NSNumberFormatter+RestClient.m
//  RestClient
//
//  Created by Axel Rivera on 12/15/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSNumberFormatter+RestClient.h"

static NSNumberFormatter *_responseTimeFormatter;

@implementation NSNumberFormatter (RestClient)

+ (NSNumberFormatter *)responseTimeFormatter
{
    if (_responseTimeFormatter == nil) {
        _responseTimeFormatter = [[NSNumberFormatter alloc] init];
        _responseTimeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _responseTimeFormatter.maximumFractionDigits = 0;
    }
    return _responseTimeFormatter;
}

@end
