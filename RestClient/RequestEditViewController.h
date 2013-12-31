//
//  RequestEditViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/30/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestEditViewController : UITableViewController

@property (strong, nonatomic) UITextField *nameTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;

@property (strong, nonatomic) RCRequest *request;
@property (copy) void(^completionBlock)(void);

- (instancetype)initWithRequest:(RCRequest *)request;

@end
