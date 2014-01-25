//
//  RCJSONObject.h
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RCJSONObjectType) {
    RCJSONObjectTypeObject = 0,
    RCJSONObjectTypeArray,
    RCJSONObjectTypeString,
    RCJSONObjectTypeNumber,
    RCJSONObjectTypeBoolean,
    RCJSONObjectTypeNull
};

@interface RCJSONObject : NSObject <NSCoding, NSCopying>

@property (assign, nonatomic) RCJSONObjectType objectType;
@property (strong, nonatomic) NSString *objectKey;
@property (strong, nonatomic) id objectValue;
@property (weak, nonatomic) RCJSONObject *parentObject;

- (BOOL)isContainer;
- (BOOL)isObject;
- (BOOL)isArray;
- (NSString *)stringValue;
- (RCJSONObjectType)parentType;

+ (RCJSONObject *)rootObject;
+ (NSString *)titleForObjectType:(RCJSONObjectType)objectType;

- (NSDictionary *)rootDictionary;

@end
