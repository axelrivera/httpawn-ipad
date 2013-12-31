//
//  PreviewViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/22/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewViewController : UITableViewController

@property (strong, nonatomic) RCRequest *request;

- (instancetype)initWithRequest:(RCRequest *)request;

@end
