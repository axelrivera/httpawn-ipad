//
//  NSString+UUID.h
//  BookUUID
//
//  Created by Axel Rivera on 2/9/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UUID)

+ (NSString *) stringWithUUID;
+ (NSString *) stringWithCleanUUID;

@end
