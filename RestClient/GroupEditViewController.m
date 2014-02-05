//
//  GroupEditViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupEditViewController.h"

@interface GroupEditViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

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
    
    if (self.editType == GroupEditTypeCreate) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(saveAction:)];

    } else {
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(saveAction:)];
        
        UIBarButtonItem *actionsItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(showActions:)];
        
        self.navigationItem.rightBarButtonItems = @[ saveItem, actionsItem ];
    }

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
        
        self.baseURLTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0,
                                                                              0.0,
                                                                              400.0,
                                                                              37.0)];
        self.baseURLTextField.placeholder = @"http://www.example.com";
        self.baseURLTextField.contentVerticalAlignment = UIViewContentModeCenter;
        self.baseURLTextField.font = [UIFont systemFontOfSize:15.0];
        self.baseURLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.baseURLTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.baseURLTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

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

        NSArray *parameterItems = @[ @"Form", @"JSON" ];
        self.parameterSegmentedControl = [[UISegmentedControl alloc] initWithItems:parameterItems];
        [self.parameterSegmentedControl setWidth:100.0 forSegmentAtIndex:0];
        [self.parameterSegmentedControl setWidth:100.0 forSegmentAtIndex:1];
        [self.parameterSegmentedControl addTarget:self
                                           action:@selector(parameterChanged:)
                                 forControlEvents:UIControlEventValueChanged];

        NSInteger index = -1;
        if ([self.groupObject.metadata.parameterEncoding isEqualToString:RCMetaParameterEncodingFormString]) {
            index = 0;
        } else if ([self.groupObject.metadata.parameterEncoding isEqualToString:RCMetaParameterEncodingJSONString]) {
            index = 1;
        }

        self.parameterSegmentedControl.selectedSegmentIndex = index;
        [self parameterChanged:self.parameterSegmentedControl];
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

- (void)showActions:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Duplicate", nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItems[1] animated:YES];
}

- (void)dismissAction:(id)sender
{
    [self.delegate groupEditViewControllerDidCancel:self];
}

- (void)parameterChanged:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.groupObject.metadata.parameterEncoding = RCMetaParameterEncodingFormString;
    } else {
        self.groupObject.metadata.parameterEncoding = RCMetaParameterEncodingJSONString;
    }
}

#pragma mark - Private Methods

- (NSArray *)currentDataSource
{
    NSMutableArray *sections = [@[] mutableCopy];

    NSMutableArray *rows = [@[] mutableCopy];

    NSDictionary *sectionDictionary = nil;
    NSDictionary *rowDictionary = nil;
    
    // Name Section
    
    rowDictionary = @{ @"text" : @"Name", @"identifier" : @"name", @"type" : @"accessory" };
    [rows addObject:rowDictionary];

    sectionDictionary = @{ @"rows" : rows };
    [sections addObject:sectionDictionary];

    if (self.editType == GroupEditTypeModify) {
        // Group Settings
        
        rows = [@[] mutableCopy];
        
        rowDictionary = @{ @"text" : @"Base URL", @"identifier" : @"base_url", @"type" : @"accessory" };
        [rows addObject:rowDictionary];
        
        rowDictionary = @{ @"text" : @"Follow Redirects", @"identifier" : @"redirect", @"type" : @"accessory" };
        [rows addObject:rowDictionary];
        
        rowDictionary = @{ @"text" : @"Parameter Encoding", @"identifier" : @"parameter_encoding", @"type" : @"accessory" };
        [rows addObject:rowDictionary];
        
        sectionDictionary = @{ @"header" : @"Group Settings",
                               @"footer" : @"The Base URL will be ignored if the request has a valid URL.",
                               @"rows" : rows };
        
        [sections addObject:sectionDictionary];
        
        // Auth Section
        
        rows = [@[] mutableCopy];

        rowDictionary = @{ @"text" : @"Enable Authentication", @"identifier" : @"enable_auth", @"type" : @"accessory" };
        [rows addObject:rowDictionary];

        rowDictionary = @{ @"text" : @"Username", @"identifier" : @"username", @"type" : @"accessory" };
        [rows addObject:rowDictionary];

        rowDictionary = @{ @"text" : @"Password", @"identifier" : @"password", @"type" : @"accessory" };
        [rows addObject:rowDictionary];

        sectionDictionary = @{ @"header" : @"Basic Authentication",
                               @"footer" : @"Passwords are saved in clear text.",
                               @"rows" : rows };
        
        [sections addObject:sectionDictionary];
    }

    return sections;
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

    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *identifier = dictionary[@"identifier"];

    if ([dictionary[@"type"] isEqualToString:@"accessory"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        NSString *textStr = dictionary[@"text"];
        id accessoryView = nil;

        if ([identifier isEqualToString:@"name"]) {
            accessoryView = self.nameTextField;
        } else if ([identifier isEqualToString:@"base_url"]) {
            accessoryView = self.baseURLTextField;
        } else if ([identifier isEqualToString:@"enable_auth"]) {
            accessoryView = self.authenticationSwitch;
        } else if ([identifier isEqualToString:@"username"]) {
            accessoryView = self.usernameTextField;
        } else if ([identifier isEqualToString:@"password"]) {
            accessoryView = self.passwordTextField;
        } else if ([identifier isEqualToString:@"redirect"]) {
            accessoryView = self.redirectSwitch;
        } else if ([identifier isEqualToString:@"parameter_encoding"]) {
            accessoryView = self.parameterSegmentedControl;
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

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
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

@end
