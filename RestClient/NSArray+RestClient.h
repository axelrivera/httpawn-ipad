//
//  NSArray+Kumo.h
//  RestClient
//
//  Created by Axel Rivera on 8/14/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (RestClient)

+ (NSArray *)availableHTTPActions;

- (NSArray *)arrayOfAvailableObjects;
- (NSDictionary *)dictionaryOfAvailableObjects;

@end
