//
//  RCGroupObject.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCGroup.h"

@interface RCGroup ()

@property (copy, nonatomic, readwrite) NSString *identifier;
@property (strong, nonatomic) NSMutableArray *groupRequests;

@end

@implementation RCGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = [[NSString stringWithUUID] copy];
        _groupName = @"";
        _groupRequests = [@[] mutableCopy];
        _metadata = [[RCMeta alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _groupName = [dictionary[@"name"] copy];

        NSArray *requestsRaw = dictionary[@"requests"];
        if (requestsRaw) {
            NSMutableArray *requests = [@[] mutableCopy];
            for (NSDictionary *dictionary in requestsRaw) {
                RCRequest *request = [[RCRequest alloc] initWithDictionary:dictionary];
                [requests addObject:request];
            }
            _groupRequests = requests;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _identifier = [coder decodeObjectForKey:@"RCGroupIdentifier"];
        _groupName = [coder decodeObjectForKey:@"RCGroupName"];
        _groupRequests = [coder decodeObjectForKey:@"RCGroupGroupRequests"];
        _metadata = [coder decodeObjectForKey:@"RCGroupMetadata"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.identifier forKey:@"RCGroupIdentifier"];
    [coder encodeObject:self.groupName forKey:@"RCGroupName"];
    [coder encodeObject:self.groupRequests forKey:@"RCGroupGroupRequests"];
    [coder encodeObject:self.metadata forKey:@"RCGroupMetadata"];
}

#pragma mark - Public Methods

- (void)addRequest:(RCRequest *)request
{
    if (request) {
        request.parentGroup = self;
        [self.groupRequests addObject:request];        
    } else {
        DLog(@"Tried to save a nil request!!!");
    }
}

- (void)insertRequest:(RCRequest *)request atIndex:(NSInteger)index
{
    if (request) {
        request.parentGroup = self;
        [self.groupRequests insertObject:request atIndex:index];
    } else {
        DLog(@"Tried to insert a nil request");
    }
}

- (void)removeRequestAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [self.groupRequests count]) {
        [self.groupRequests removeObjectAtIndex:index];
    }
}

- (void)removeAllRequests
{
    [self.groupRequests removeAllObjects];
}

- (NSArray *)requests
{
    return self.groupRequests;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if ([object respondsToSelector:@selector(identifier)]) {
		NSString *myStr = [self identifier];
		NSString *theirStr = [object identifier];
		return myStr && theirStr ? [myStr isEqualToString:theirStr] : NO;
	}
	return NO;
}

- (NSUInteger)hash
{
    return [self identifier] ? [[self identifier] hash] : [super hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Group Name: %@, Requests: %ld", self.groupName, (long)[self.groupRequests count]];
}

@end
