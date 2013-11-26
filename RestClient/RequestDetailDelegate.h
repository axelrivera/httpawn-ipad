//
//  RequestDetailDelegate.h
//  RestClient
//
//  Created by Axel Rivera on 11/22/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRequest.h"

typedef NS_ENUM(NSInteger, RCRequestType) {
    RCRequestTypeGroup = 0,
    RCRequestTypeHistory
};

@protocol RequestDetailDelegate <NSObject>

- (void)shouldUpdateRequest:(RCRequest *)request requestType:(RCRequestType)requestType;

@end
