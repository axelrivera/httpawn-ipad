//
//  RestClientData.m
//  RestClient
//
//  Created by Axel Rivera on 11/21/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RestClientData.h"

@implementation RestClientData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groups = [@[] mutableCopy];
        _history = [@[] mutableCopy];
        _recentHosts = [@[] mutableCopy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _groups = [coder decodeObjectForKey:@"RestClientDataGroups"];
        _history = [coder decodeObjectForKey:@"RestClientDataHistory"];
        _recentHosts = [coder decodeObjectForKey:@"RestClientDataRecentHosts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.groups forKey:@"RestClientDataGroups"];
    [coder encodeObject:self.history forKey:@"RestClientDataHistory"];
    [coder encodeObject:self.recentHosts forKey:@"RestClientDataRecentHosts"];
}

#pragma - Public Methods

- (void)loadData
{
    RestClientData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:pathInDocumentDirectory(kRestClientDataFile)];
    if (data) {
        self.groups = data.groups;
        self.history = data.history;
        self.recentHosts = data.recentHosts;
    }
}

- (void)saveData
{
    [NSKeyedArchiver archiveRootObject:self toFile:pathInDocumentDirectory(kRestClientDataFile)];
}

- (NSArray *)groupSelectObjectsWithSelectedGroup:(RCGroup *)selectedGroup
{
    NSMutableArray *groups = [@[] mutableCopy];
    for (RCGroup *group in self.groups) {
        RCSelect *select = [[RCSelect alloc] initWithName:group.groupName value:group.identifier];
        if ([select isEqual:selectedGroup]) {
            select.selected = YES;
        }
        [groups addObject:select];
    }
    return groups;
}

- (RCGroup *)groupWithIdentifier:(NSString *)identifier
{
    RCGroup *group = nil;
    for (RCGroup *tmpGroup in self.groups) {
        if ([tmpGroup.identifier isEqualToString:identifier]) {
            group = tmpGroup;
            break;
        }
    }
    return group;
}

- (BOOL)containsGroup:(RCGroup *)group
{
    return [self.groups containsObject:group];
}

- (void)addRequestToHistory:(RCRequest *)request
{
    if (self.history == nil || [self.history isEqual:[NSNull null]]) {
        self.history = [@[] mutableCopy];
    }

    if ([self.history count] > 0) {
        RCRequest *firstRequest = self.history[0];
        if ([request isEqualToRequest:firstRequest]) {
            return; // Ignore if the request about to insert is the same as the first object in history
        }
    }

    RCRequest *tmpRequest = [request copy];
    [tmpRequest sanitize];
    
    [self.history insertObject:tmpRequest atIndex:0];
    if ([self.history count] > kMaximumHistoryItems) {
        NSInteger length = [self.history count] - kMaximumHistoryItems;
        [self.history removeObjectsInRange:NSMakeRange(kMaximumHistoryItems, length)];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HistoryDidUpdateNotification
                                                        object:nil
                                                      userInfo:@{ kRCRequestKey: tmpRequest }];
}

- (void)addRecentHost:(NSString *)host
{
    if (IsEmpty(host)) {
        return;
    }

    if (self.recentHosts == nil || [self.recentHosts isEqual:[NSNull null]]) {
        self.recentHosts = [@[] mutableCopy];
    }

    BOOL found = NO;
    BOOL index = -1;
    if ([self.recentHosts count] > 0) {
        NSInteger totalHosts = [self.recentHosts count];
        for (NSInteger i = 0; i < totalHosts; i++) {
            NSString *string = self.recentHosts[i];
            if ([string isEqualToString:host]) {
                found = YES;
                index = i;
                break;
            }
        }
    }

    if (found) {
        [self.recentHosts removeObjectAtIndex:index];
    }

    [self.recentHosts insertObject:host atIndex:0];

    if ([self.recentHosts count] > kMaximumRecentHosts) {
        NSInteger length = [self.recentHosts count] - kMaximumRecentHosts;
        [self.recentHosts removeObjectsInRange:NSMakeRange(kMaximumRecentHosts, length)];
    }
}

#pragma mark - Singleton Methods

+ (RestClientData *)sharedData
{
    static RestClientData *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[RestClientData alloc] init];
    });
    return sharedData;
}

@end
