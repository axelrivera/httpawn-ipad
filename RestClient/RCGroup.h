//
//  RCGroupObject.h
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCGroup : NSObject <NSCoding>

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *requests;

@end
