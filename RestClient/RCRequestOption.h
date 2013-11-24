//
//  RequestOption.h
//  Kumo
//
//  Created by Axel Rivera on 8/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCRequestOption : NSObject <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *objectName;
@property (copy, nonatomic) NSString *objectValue;
@property (assign, nonatomic, getter = isOn) BOOL on;

- (NSString *)stringValue;

- (BOOL)isEqualToRequestOption:(RCRequestOption *)requestOption;

@end
