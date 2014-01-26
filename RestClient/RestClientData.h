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
@property (strong, nonatomic) NSMutableArray *recentHosts;

- (void)loadData;
- (void)saveData;

- (NSArray *)groupSelectObjectsWithSelectedGroup:(RCGroup *)selectedGroup;
- (RCGroup *)groupWithIdentifier:(NSString *)identifier;
- (BOOL)containsGroup:(RCGroup *)group;

- (void)addRequestToHistory:(RCRequest *)request;
- (void)addRecentHost:(NSString *)host;

+ (RestClientData *)sharedData;


@end
