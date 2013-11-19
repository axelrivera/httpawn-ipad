//
//  RCInputObject.h
//  RestClient
//
//  Created by Axel Rivera on 11/17/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCInputObject : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *value;
@property (assign, nonatomic, getter = isActive) BOOL active;

- (BOOL)isValid;

@end
