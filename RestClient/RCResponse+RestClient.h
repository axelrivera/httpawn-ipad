//
//  RCResponse+RestClient.h
//  RestClient
//
//  Created by Axel Rivera on 12/6/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RCResponse.h"

@interface RCResponse (RestClient)

- (NSString *)formattedHTMLBodyString;
- (NSString *)formattedRawBodyString;

@end
