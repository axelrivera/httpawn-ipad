//
//  NSJSONSerialization+File.h
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (File)

+ (id)rc_JSONObjectWithContentsOfFile:(NSString *)file;
+ (id)rc_JSONObjectWithContentsOfURL:(NSURL *)URL;
+ (NSString *)rc_prettyPrintedJSONStringWithDictionary:(NSDictionary *)dictionary;

@end
