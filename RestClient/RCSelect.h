//
//  RCSelect.h
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSelect : NSObject <NSCopying>

@property (copy, nonatomic) NSString *selectName;
@property (copy, nonatomic) NSString *selectValue;
@property (assign, nonatomic, getter = isSelected) BOOL selected;

- (instancetype)initWithName:(NSString *)name value:(NSString *)value;

@end
