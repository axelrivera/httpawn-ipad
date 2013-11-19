//
//  RCInputObject.m
//  RestClient
//
//  Created by Axel Rivera on 11/17/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCInputObject.h"

@implementation RCInputObject

- (id)init
{
    self = [super init];
    if (self) {
        _name = @"";
        _value = @"";
        _active = YES;
    }
    return self;
}

- (BOOL)isValid
{
    NSString *name = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return IsEmpty(name) ? NO : YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Input Object: %@, %@, %d", self.name, self.value, self.isActive];
}

@end
