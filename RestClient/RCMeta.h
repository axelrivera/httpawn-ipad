//
//  RCMeta.h
//  RestClient
//
//  Created by Axel Rivera on 1/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCMeta : NSObject <NSCopying, NSCoding>

@property (assign, nonatomic) BOOL enableAuth;
@property (copy, nonatomic) NSString *basicAuthUsername;
@property (copy, nonatomic) NSString *basicAuthPassword;
@property (assign, nonatomic) BOOL followRedirects;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
