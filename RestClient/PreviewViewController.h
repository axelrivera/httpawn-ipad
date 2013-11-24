//
//  PreviewViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/22/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewViewController : UITableViewController

@property (strong, nonatomic) NSString *URLString;
@property (strong, nonatomic) NSArray *headers;
@property (strong, nonatomic) NSArray *parameters;

- (id)initWithURLString:(NSString *)URLString headers:(NSArray *)headers parameters:(NSArray *)parameters;

@end
