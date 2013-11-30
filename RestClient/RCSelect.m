//
//  RCSelect.m
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCSelect.h"

@implementation RCSelect

- (id)initWithName:(NSString *)name value:(NSString *)value
{
    self = [super init];
    if (self) {
        _selectName = [name copy];
        _selectValue = [value copy];
        _selected = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    RCSelect *mySelect = [[RCSelect alloc] init];
    mySelect.selectName = self.selectName;
    mySelect.selectValue = self.selectValue;
    mySelect.selected = self.selected;

    return mySelect;
}

- (BOOL)isEqual:(id)object
{
	if (self == object) return YES;

	if ([object respondsToSelector:@selector(selectValue)]) {
		NSString *myValue = [self selectValue];
		NSString *theirValue = [object selectValue];
		return myValue && theirValue ? [myValue isEqualToString:theirValue] : NO;
	}
	return NO;
}

- (NSUInteger)hash
{
    return [self selectValue] ? [[self selectValue] hash] : [super hash];
}

@end
