//
//  GroupEditViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/18/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "GroupEditViewController.h"

@interface GroupEditViewController () <UITextFieldDelegate>

@end

@implementation GroupEditViewController

- (id)init
{
    self = [super initWithNibName:@"GroupEditViewController" bundle:nil];
    if (self) {
        self.title = @"Create Group";
        _editType = GroupEditTypeCreate;
        _groupObject = nil;
    }
    return self;
}

- (id)initWithGroupObject:(RCGroupObject *)groupObject
{
    self = [self init];
    if (self) {
        self.title = @"Edit Group";
        _editType = GroupEditTypeModify;
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissAction:)];

    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 37.0)];
    self.nameTextField.placeholder = @"Enter Name";
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameTextField.contentVerticalAlignment = UIViewContentModeCenter;
    self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextField.delegate = self;

    if (self.editType == GroupEditTypeModify) {
        self.nameTextField.text = self.groupObject.name;
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

    if (self.editType == GroupEditTypeCreate) {
        self.groupObject = [[RCGroupObject alloc] init];
    }

    self.groupObject.name = self.nameTextField.text;

    [self.delegate groupEditViewController:self didFinishWithType:self.editType object:self.groupObject];
}

- (void)dismissAction:(id)sender
{
    [self.delegate groupEditViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = @"Group Name";
    cell.accessoryView = self.nameTextField;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
