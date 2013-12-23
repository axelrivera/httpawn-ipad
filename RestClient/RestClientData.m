//
//  RestClientData.m
//  RestClient
//
//  Created by Axel Rivera on 11/21/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RestClientData.h"

@implementation RestClientData

- (id)init
{
    self = [super init];
    if (self) {
        _groups = [@[] mutableCopy];
        _history = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _groups = [coder decodeObjectForKey:@"RestClientDataGroups"];
        _history = [coder decodeObjectForKey:@"RestClientDataHistory"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.groups forKey:@"RestClientDataGroups"];
    [coder encodeObject:self.history forKey:@"RestClientDataHistory"];
}

#pragma - Public Methods

- (void)loadData
{
    RestClientData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:pathInDocumentDirectory(kRestClientDataFile)];
    if (data) {
        self.groups = data.groups;
        self.history = data.history;
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
