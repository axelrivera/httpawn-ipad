//
//  NSJSONSerialization+File.m
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "NSJSONSerialization+File.h"

@implementation NSJSONSerialization (File)

+ (id)rc_JSONObjectWithContentsOfFile:(NSString *)file
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:file];
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return JSON;
}

+ (id)rc_JSONObjectWithContentsOfURL:(NSURL *)URL
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return JSON;
}

+ (NSString *)rc_prettyPrintedJSONStringWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil) {
        dictionary = @{};
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:NULL];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end
