//
//  RequestDetailDelegate.h
//  RestClient
//
//  Created by Axel Rivera on 11/22/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RCRequest.h"

@protocol RequestDetailDelegate <NSObject>

- (void)shouldUpdateRequest:(RCRequest *)request;

@end
