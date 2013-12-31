//
//  RequestOption.m
//  Kumo
//
//  Created by Axel Rivera on 8/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCRequestOption.h"

@interface RCRequestOption ()

@end

@implementation RCRequestOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectName = [@"" copy];
        _objectValue = [@"" copy];
        _on = YES;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        _objectName = [dictionary[@"name"] copy];
        _objectValue = [dictionary[@"value"] copy];

        NSNumber *onNumber = dictionary[@"enabled"];
        if (onNumber) {
            _on = [onNumber boolValue];
        }
    }
    return self;
}

#pragma mark - NSCoding Methods

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _objectName = [[coder decodeObjectForKey:@"RCRequestOptionObjectName"] copy];
        _objectValue = [[coder decodeObjectForKey:@"RCRequestOptionObjectValue"] copy];
        _on = [coder decodeBoolForKey:@"RCRequestOptionOn"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.objectName forKey:@"RCRequestOptionObjectName"];
    [coder encodeObject:self.objectValue forKey:@"RCRequestOptionObjectValue"];
    [coder encodeBool:self.isOn forKey:@"RCRequestOptionOn"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    RCRequestOption *myOption = [[RCRequestOption alloc] init];
    myOption.objectName = self.objectName;
    myOption.objectValue = self.objectValue;
    myOption.on = self.isOn;

    return myOption;
}

- (NSString *)stringValue
{
    return self.objectValue;
}

- (BOOL)isEqualToRequestOption:(RCRequestOption *)requestOption
{
    BOOL isNameEqual = NO;
    BOOL isValueEqual = NO;
    BOOL isOnEqual = NO;

    NSString *myName = [self objectName];
    NSString *theirName = [requestOption objectName];
    isNameEqual = myName && theirName ? [myName isEqualToString:theirName] : NO;

    NSString *myValue = [self objectValue];
    NSString *theirValue = [requestOption objectValue];
    isValueEqual = myValue && theirValue ? [myValue isEqualToString:theirValue] : NO;

    BOOL myOn = [self isOn];
    BOOL theirOn = [requestOption isOn];
    isOnEqual = myOn == theirOn;

	return isNameEqual && isValueEqual && isOnEqual ? YES : NO;
}

@end
