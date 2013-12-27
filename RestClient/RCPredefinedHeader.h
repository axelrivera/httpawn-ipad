//
//  RCPredefinedHeader.h
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCPredefinedHeader : NSObject

@property (copy, nonatomic) NSString *headerName;
@property (strong, nonatomic) NSArray *headerValues;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)allPredefinedHeaders;

@end
