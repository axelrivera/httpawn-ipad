//
//  AdvancedRequestViewController.m
//  RestClient
//
//  Created by Axel Rivera on 12/1/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "AdvancedRequestViewController.h"

@interface AdvancedRequestViewController ()

@end

@implementation AdvancedRequestViewController

- (instancetype)init
{
    self = [super initWithNibName:@"AdvancedRequestViewController" bundle:nil];
    if (self) {
        self.title = @"Advanced";
        _request = nil;
    }
    return self;
}

- (instancetype)initWithRequest:(RCRequest *)request
{
    self = [self init];
    if (self) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismissAction:)];

    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                           0.0,
                                                                           400.0,
                                                                           37.0)];
    self.usernameTextField.placeholder = @"Enter Username";
    self.usernameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.usernameTextField.font = [UIFont systemFontOfSize:15.0];
    self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                           0.0,
                                                                           400.0,
                                                                           37.0)];
    self.passwordTextField.placeholder = @"Enter Password";
    self.passwordTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.passwordTextField.font = [UIFont systemFontOfSize:15.0];
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.authenticationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];

    self.redirectSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];

    if (self.request) {
        self.usernameTextField.text = self.request.metadata.basicAuthUsername;
        self.passwordTextField.text = self.request.metadata.basicAuthPassword;
        self.authenticationSwitch.on = self.request.metadata.enableAuth;
        self.redirectSwitch.on = self.request.metadata.followRedirects;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.view endEditing:YES];

    if (self.request) {
        self.request.metadata.enableAuth = self.authenticationSwitch.on;
        self.request.metadata.basicAuthUsername = self.usernameTextField.text;
        self.request.metadata.basicAuthPassword = self.passwordTextField.text;
        self.request.metadata.followRedirects = self.redirectSwitch.on;
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 3;
    } else if (section == 1) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *textStr = nil;
    UIView *accessoryView;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            textStr = @"Enable Authentication";
            accessoryView = self.authenticationSwitch;
        } else if (indexPath.row == 1) {
            textStr = @"Username";
            accessoryView = self.usernameTextField;
        } else {
            textStr = @"Password";
            accessoryView = self.passwordTextField;
        }
    } else if (indexPath.section == 1) {
        textStr = @"Follow Redirects";
        accessoryView = self.redirectSwitch;
    }

    cell.textLabel.text = textStr;
    cell.accessoryView = accessoryView;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Basic Authentication";
    } else {
        title = @"Other";
    }
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Passwords are saved in clear text.";
    } else {
        title = @"Request options will override Group options.";
    }
    return title;
}

@end
