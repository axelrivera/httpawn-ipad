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

@end
