//
//  AdvancedRequestViewController.h
//  RestClient
//
//  Created by Axel Rivera on 12/1/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvancedRequestViewController : UITableViewController

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UISwitch *authenticationSwitch;
@property (strong, nonatomic) UISwitch *redirectSwitch;

@property (strong, nonatomic) RCRequest *request;

- (id)initWithRequest:(RCRequest *)request;

@end
