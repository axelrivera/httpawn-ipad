//
//  NSString+RestClient.h
//  RestClient
//
//  Created by Axel Rivera on 8/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RestClient)

- (BOOL)isEmpty;
- (BOOL)isValidHTTPURL;

- (NSString *)cleanString;

@end
