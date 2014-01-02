//
//  GroupEditViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupEditViewController.h"

@interface GroupEditViewController () <UITextFieldDelegate, UIAlertViewDelegate>

- (NSArray *)currentDataSource;

@end

@implementation GroupEditViewController

- (instancetype)init
{
    self = [super initWithNibName:@"GroupEditViewController" bundle:nil];
    if (self) {
        self.title = @"Create Group";
        _editType = GroupEditTypeCreate;
        _groupObject = nil;
    }
    return self;
}

- (instancetype)initWithType:(GroupEditType)type groupObject:(RCGroup *)groupObject
{
    self = [self init];
    if (self) {
        if (type == GroupEditTypeModify) {
            self.title = @"Edit Group";
        }
        _editType = type;
        _groupObject = groupObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *rightStr = self.editType == GroupEditTypeCreate ? @"Create" : @"Save";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightStr
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(saveAction:)];

    if ([self.delegate respondsToSelector:@selector(groupEditViewControllerDidCancel:)]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(dismissAction:)];
    }

    self.dataSource = [self currentDataSource];

    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 37.0)];
    self.nameTextField.placeholder = @"Enter Group Name";
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.delegate = self;

    if (self.editType == GroupEditTypeModify) {
        self.nameTextField.text = self.groupObject.groupName;

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

        if (self.groupObject) {
            self.usernameTextField.text = self.groupObject.metadata.basicAuthUsername;
            self.passwordTextField.text = self.groupObject.metadata.basicAuthPassword;
            self.authenticationSwitch.on = self.groupObject.metadata.enableAuth;
            self.redirectSwitch.on = self.self.groupObject.metadata.followRedirects;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)saveAction:(id)sender
{
    [self.view endEditing:YES];

    NSString *nameStr = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (IsEmpty(nameStr)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Group Name"
                                                            message:@"Name cannot be empty."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    if (self.editType == GroupEditTypeCreate) {
        self.groupObject = [[RCGroup alloc] init];
    }

    self.groupObject.groupName = self.nameTextField.text;

    if (self.editType == GroupEditTypeModify) {
        self.groupObject.metadata.enableAuth = self.authenticationSwitch.on;
        self.groupObject.metadata.basicAuthUsername = self.usernameTextField.text;
        self.groupObject.metadata.basicAuthPassword = self.passwordTextField.text;
        self.groupObject.metadata.followRedirects = self.redirectSwitch.on;
    }

    [self.delegate groupEditViewController:self didFinishWithType:self.editType object:self.groupObject];
}

- (void)dismissAction:(id)sender
{
    [self.delegate groupEditViewControllerDidCancel:self];
}

#pragma mark - Private Methods

- (NSArray *)currentDataSource
{
    NSMutableArray *array = [@[] mutableCopy];

    NSMutableArray *rows = [@[] mutableCopy];

    NSDictionary *dictionary = nil;

    dictionary = @{ @"text" : @"Name", @"identifier" : @"name", @"type" : @"accessory" };
    [rows addObject:dictionary];

    dictionary = @{ @"rows" : rows };
    [array addObject:dictionary];

    if (self.editType == GroupEditTypeModify) {
        rows = [@[] mutableCopy];

        dictionary = @{ @"text" : @"Enable Authentication", @"identifier" : @"enable_auth", @"type" : @"accessory" };
        [rows addObject:dictionary];

        dictionary = @{ @"text" : @"Username", @"identifier" : @"username", @"type" : @"accessory" };
        [rows addObject:dictionary];

        dictionary = @{ @"text" : @"Password", @"identifier" : @"password", @"type" : @"accessory" };
        [rows addObject:dictionary];

        dictionary = @{ @"header" : @"Basic Authentication",
                        @"footer" : @"Passwords are saved in clear text.",
                        @"rows" : rows };

        [array addObject:dictionary];

        rows = [@[] mutableCopy];

        dictionary = @{ @"text" : @"Follow Redirects", @"identifier" : @"redirect", @"type" : @"accessory" };
        [rows addObject:dictionary];

        dictionary = @{ @"header" : @"Other", @"rows" : rows };
        [array addObject:dictionary];

        rows = [@[] mutableCopy];

        dictionary = @{ @"text" : @"Delete Group", @"identifier" : @"delete" };
        [rows addObject:dictionary];

        dictionary = @{ @"rows" : rows };
        [array addObject:dictionary];
    }

    return array;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section][@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *DeleteIdentifier = @"DeleteCell";

    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];

    if ([dictionary[@"identifier"] isEqualToString:@"delete"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeleteIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteIdentifier];
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        }

        NSString *textStr = dictionary[@"text"];

        cell.textLabel.text = textStr;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        return cell;
    }

    if ([dictionary[@"type"] isEqualToString:@"accessory"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        NSString *textStr = dictionary[@"text"];
        id accessoryView = nil;

        NSString *identifier = dictionary[@"identifier"];
        if ([identifier isEqualToString:@"name"]) {
            accessoryView = self.nameTextField;
        } else if ([identifier isEqualToString:@"enable_auth"]) {
            accessoryView = self.authenticationSwitch;
        } else if ([identifier isEqualToString:@"username"]) {
            accessoryView = self.usernameTextField;
        } else if ([identifier isEqualToString:@"password"]) {
            accessoryView = self.passwordTextField;
        } else if ([identifier isEqualToString:@"redirect"]) {
            accessoryView = self.redirectSwitch;
        }

        cell.textLabel.text = textStr;
        cell.accessoryView = accessoryView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }

    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];

    if ([dictionary[@"identifier"] isEqualToString:@"delete"]) {
        NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the group \"%@\"? This action can't be undone.",
                           self.groupObject.groupName];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Group"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Continue", nil];
        [alertView show];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource[section][@"header"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.dataSource[section][@"footer"];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(groupEditViewController:shouldDeleteGroupObject:)]) {
            [self.delegate groupEditViewController:self shouldDeleteGroupObject:self.groupObject];
        }
    }
}

@end
