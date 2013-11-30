//
//  RCGroupObject.h
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCRequest;

@interface RCGroup : NSObject <NSCoding>

@property (copy, nonatomic, readonly) NSString *identifier;
@property (copy, nonatomic) NSString *groupName;

- (void)addRequest:(RCRequest *)request;
- (void)insertRequest:(RCRequest *)request atIndex:(NSInteger)index;
- (void)removeRequestAtIndex:(NSInteger)index;
- (void)removeAllRequests;

- (NSArray *)requests;

@end
