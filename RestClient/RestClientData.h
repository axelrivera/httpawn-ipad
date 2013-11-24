//
//  RestClientData.h
//  RestClient
//
//  Created by Axel Rivera on 11/21/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestClientData : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *history;

- (void)loadData;
- (void)saveData;

- (void)addRequestToHistory:(RCRequest *)request;

+ (RestClientData *)sharedData;

@end
