//
//  RequestOption.m
//  Kumo
//
//  Created by Axel Rivera on 8/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCRequestOption.h"

#define kParameterRegex @"\\d+.(\\w.|\\[\\d+\\].)+"

static NSRegularExpression *_regex;

@interface RCRequestOption ()

+ (NSRegularExpression *)regex;

@end

@implementation RCRequestOption

- (id)init
{
    self = [super init];
    if (self) {
        _objectName = [@"" copy];
        _objectValue = [@"" copy];
        _temporaryValue = nil;
        _on = YES;
    }
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _objectName = [[coder decodeObjectForKey:@"RCRequestOptionObjectName"] copy];
        _objectValue = [[coder decodeObjectForKey:@"RCRequestOptionObjectValue"] copy];
        _on = [coder decodeBoolForKey:@"RCRequestOptionOn"];
        _temporaryValue = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.objectName forKey:@"RCRequestOptionObjectName"];
    [coder encodeObject:self.objectValue forKey:@"RCRequestOptionObjectValue"];
    [coder encodeBool:self.isOn forKey:@"RCRequestOptionOn"];
}

- (BOOL)isRegex
{
    NSRange range = [[RCRequestOption regex] rangeOfFirstMatchInString:self.objectValue
                                                             options:0
                                                               range:NSMakeRange(0, [self.objectValue length])];
    return range.location == NSNotFound ? NO : YES;
}

- (NSString *)stringValue
{
    return [self isRegex] && !IsEmpty(self.temporaryValue) ? self.temporaryValue : self.objectValue;
}

+ (NSRegularExpression *)regex
{
    if (_regex == nil) {
        _regex = [NSRegularExpression regularExpressionWithPattern:kParameterRegex
                                                           options:0
                                                             error:nil];
    }
    return _regex;
}

@end
