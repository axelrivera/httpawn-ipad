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

@end