//
//  NSString+UUID.m
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *) stringWithUUID
{
	CFUUIDRef uuidObj = CFUUIDCreate(nil); //create a new UUID
	//get the string representation of the UUID
	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	
	return uuidString;
}

+ (NSString *)stringWithCleanUUID
{
    NSString *uuid = [[self class] stringWithUUID];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuid = [uuid lowercaseString];
    return uuid;
}

@end
