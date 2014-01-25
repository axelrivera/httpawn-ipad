//
//  RCJSONObject.m
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "RCJSONObject.h"

@interface RCJSONObject ()

- (NSDictionary *)dictionaryWithObject:(RCJSONObject *)object;
- (NSArray *)arrayWithArrayObject:(RCJSONObject *)object;

@end

@implementation RCJSONObject

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _objectType = [coder decodeIntegerForKey:@"RCJSONObjectObjectType"];
        _objectKey = [coder decodeObjectForKey:@"RCJSONObjectObjectKey"];
        _objectValue = [coder decodeObjectForKey:@"RCJSONObjectObjectValue"];
        _parentObject = [coder decodeObjectForKey:@"RCJSONObjectParentObject"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.objectType forKey:@"RCJSONObjectObjectType"];
    [coder encodeObject:self.objectKey forKey:@"RCJSONObjectObjectKey"];
    [coder encodeObject:self.objectValue forKey:@"RCJSONObjectObjectValue"];
    [coder encodeConditionalObject:self.parentObject forKey:@"RCJSONObjectParentObject"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    RCJSONObject *object = [[self class] allocWithZone:zone];
    object.objectType = self.objectType;
    object.objectKey = self.objectKey;

    if ([self.objectValue isKindOfClass:[NSArray class]]) {
        object.objectValue = [[NSMutableArray alloc] initWithArray:self.objectValue copyItems:YES];
    } else if ([self.objectValue isKindOfClass:[NSDictionary class]]) {
        object.objectValue = [[NSMutableDictionary alloc] initWithDictionary:self.objectValue copyItems:YES];
    } else {
        object.objectValue = self.objectValue;
    }

    object.parentObject = self.parentObject;

    return object;
}

- (BOOL)isContainer
{
    return [self isObject] || [self isArray];
}

- (BOOL)isObject
{
    return self.objectType == RCJSONObjectTypeObject;
}

- (BOOL)isArray
{
    return self.objectType == RCJSONObjectTypeArray;
}

- (RCJSONObjectType)parentType
{
    return self.parentObject == nil ? self.objectType : self.parentObject.objectType;
}

- (NSString *)stringValue
{
    NSString *string = @"";
    switch (self.objectType) {
        case RCJSONObjectTypeNumber:
            string = [self.objectValue stringValue];
            break;
        case RCJSONObjectTypeString:
            string = self.objectValue;
            break;
        case RCJSONObjectTypeBoolean:
            string = [self.objectValue boolValue] == YES ? @"true" : @"false";
            break;
        case RCJSONObjectTypeNull:
            string = @"null";
            break;
        default:
            break;
    }

    return string;
}

- (NSDictionary *)rootDictionary
{
    NSDictionary *dictionary = @{};
    if (self.parentObject == nil && [self isObject]) {
        dictionary = [self dictionaryWithObject:self];
    }
    return dictionary;
}

- (NSDictionary *)dictionaryWithObject:(RCJSONObject *)object
{
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    for (RCJSONObject *tmpObject in object.objectValue) {
        id value = nil;
        if ([tmpObject isObject]) {
            value = [self dictionaryWithObject:tmpObject];
        } else if ([tmpObject isArray]) {
            value = [self arrayWithArrayObject:tmpObject];
        } else {
            value = tmpObject.objectValue;
        }

        if (tmpObject.objectKey) {
            dictionary[tmpObject.objectKey] = value;
        } else {
            dictionary = value;
        }
    }
    return dictionary;
}

- (NSArray *)arrayWithArrayObject:(RCJSONObject *)object
{
    NSMutableArray *array = [@[] mutableCopy];
    for (RCJSONObject *tmpObject in object.objectValue) {
        id value = nil;
        if ([tmpObject isObject]) {
            value = [self dictionaryWithObject:tmpObject];
        } else if ([tmpObject isArray]) {
            value = [self arrayWithArrayObject:tmpObject];
        } else {
            value = tmpObject.objectValue;
        }
        [array addObject:value];
    }
    return array;
}

+ (RCJSONObject *)rootObject
{
    RCJSONObject *object = [[RCJSONObject alloc] init];
    object.objectType = RCJSONObjectTypeObject;
    object.objectKey = nil;
    object.objectValue = [@[] mutableCopy];
    object.parentObject = nil;

    return object;
}

+ (NSString *)titleForObjectType:(RCJSONObjectType)objectType
{
    NSString *title = nil;
    switch (objectType) {
        case RCJSONObjectTypeObject:
            title = @"Object";
            break;
        case RCJSONObjectTypeArray:
            title = @"Array";
            break;
        case RCJSONObjectTypeString:
            title = @"String";
            break;
        case RCJSONObjectTypeNumber:
            title = @"Number";
            break;
        case RCJSONObjectTypeBoolean:
            title = @"Boolean";
            break;
        case RCJSONObjectTypeNull:
            title = @"Null";
            break;
        default:
            title = @"Object";
            break;
    }
    return title;
}

@end
