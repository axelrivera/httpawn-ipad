//
//  GroupEditViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupEditViewController.h"

@interface GroupEditViewController () <UITextFieldDelegate, UIAlertViewDelegate>

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

    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 37.0)];
    self.nameTextField.placeholder = @"Enter Group Name";
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.delegate = self;

    if (self.editType == GroupEditTypeModify) {
        self.nameTextField.text = self.groupObject.groupName;
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

    [self.delegate groupEditViewController:self didFinishWithType:self.editType object:self.groupObject];
}

- (void)dismissAction:(id)sender
{
    [self.delegate groupEditViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    if (self.editType == GroupEditTypeModify) {
        sections++;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *DeleteIdentifier = @"DeleteCell";

    if (self.editType == GroupEditTypeModify && indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeleteIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteIdentifier];
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        }

        cell.textLabel.text = @"Delete Group";

        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = @"Name";
    cell.accessoryView = self.nameTextField;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.editType == GroupEditTypeModify && indexPath.section == 1) {
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
