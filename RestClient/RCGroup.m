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

- (id)init
{
    self = [super init];
    if (self) {
        _identifier = [[NSString stringWithUUID] copy];
        _groupName = @"";
        _groupRequests = [@[] mutableCopy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _identifier = [coder decodeObjectForKey:@"RCGroupIdentifier"];
        _groupName = [coder decodeObjectForKey:@"RCGroupName"];
        _groupRequests = [coder decodeObjectForKey:@"RCGroupGroupRequests"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.identifier forKey:@"RCGroupIdentifier"];
    [coder encodeObject:self.groupName forKey:@"RCGroupName"];
    [coder encodeObject:self.groupRequests forKey:@"RCGroupGroupRequests"];
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
