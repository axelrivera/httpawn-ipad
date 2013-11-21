//
//  RCGroupObject.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCGroup.h"

@implementation RCGroup

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"RCGroupName"];
        _requests = [coder decodeObjectForKey:@"RCGroupRequests"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"RCGroupName"];
    [coder encodeObject:self.requests forKey:@"RCGroupRequests"];
}

@end
