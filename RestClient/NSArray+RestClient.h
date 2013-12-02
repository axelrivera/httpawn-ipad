//
//  NSArray+Kumo.h
//  RestClient
//
//  Created by Axel Rivera on 8/14/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const RCRequestMethodGet;
FOUNDATION_EXPORT NSString * const RCRequestMethodPost;
FOUNDATION_EXPORT NSString * const RCRequestMethodPut;
FOUNDATION_EXPORT NSString * const RCRequestMethodDelete;
FOUNDATION_EXPORT NSString * const RCRequestMethodHead;
FOUNDATION_EXPORT NSString * const RCRequestMethodTrace;
FOUNDATION_EXPORT NSString * const RCRequestMethodPatch;

@interface NSArray (RestClient)

+ (NSArray *)availableHTTPActions;

- (NSArray *)arrayOfAvailableObjects;
- (NSDictionary *)dictionaryOfAvailableObjects;

@end
